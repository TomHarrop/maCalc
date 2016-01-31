library(shiny)
library(ggplot2)
library(gridExtra)

# input$target.ma: desired mechanical advantage

shinyServer(
  function(input, output) {
    output$ma.plot <- renderPlot({
      # default values for now
      # brown bomba
      YO <- 115
      PO <- 80
      DO <- 30
      W <- 30
      # BR-CX70
      PA <- 65 ## measured
      delta <- 20.5 ## measured
      
      # calculate radians from degrees
      rad <- function(degrees) {
        degrees * pi / 180
      }
      
      # mechanical advantage function
      CalculateMechanicalAdvantage <- function(
        L, YO, PA, PO, DO, delta, W) {
        # Computes the mechanical advantage
        # 
        # Args:
        #   PA = cantilever arm length in mm
        #   DO = vertical distance from canti studs to centre of rim in mm
        #   YO = yoke height (measured from canti studs) in mm
        #   PO = fork width at canti studs in mm
        #   delta = angle between canti arm and brake pad attachment arm
        #   L = length of brake pad from brake pad attachment arm to rim in mm
        #       (15 ~ 20 mm)
        #   W = rim width in mm
        # Returns:
        #   Mechanical advantage (float)
        
        # calculate alpha, i.e. the canti angle (degrees from vertical. e.g. a
        # canti arm parallel with the fork has alpha == 0)
        alpha <- (180 * atan(DO / ((0.5 * PO) - (0.5 * W) - L)) / pi) + delta - 90
        # calculate the MA
        numerator <- YO - (cos(rad(alpha)) * PA)
        denominator <- (sin(rad(alpha)) * PA ) + (0.5 * PO)
        gamma <- atan(numerator / denominator) * 180 / pi
        beta <- gamma + 90 - alpha
        term.1 <- sin(rad(gamma))^-1
        term.2 <- sin(rad(beta))
        term.3 <- PA/DO
        term.1 * term.2 * term.3
      }
      
      OptimiseMechanicalAdvantage <- function(
        vars, target.ma, PA = PA, PO = PO, DO = DO, delta = delta, W = W) {
        # Wrapper to CalculateMechanicalAdvantage() for optim() call
        # Args:
        #   vars = vector of opt.YO (YO) and opt.L (L)
        #   target.ma = desired mechanical advantage
        #   PA = cantilever arm length in mm
        #   DO = vertical distance from canti studs to centre of rim in mm
        #   PO = fork width at canti studs in mm
        #   delta = angle between canti arm and brake pad attachment arm
        #   W = rim width in mm
        # Returns:
        #   Difference between target.ma and calculated ma
        
        opt.YO <- vars["YO"]
        opt.L <- vars["L"]
        
        ma <- CalculateMechanicalAdvantage(
          L = opt.L, YO = opt.YO, PA = PA, PO = PO, DO = DO, delta = delta, W = W)
        
        abs(target.ma - ma)
      }
      
      # variables to optimise: length of brake pad from brake pad attachment arm
      # to rim and yoke height
      vars <- c(L = 15, YO = 115)
      
      # run the optimisation
      optimised.ma <- optim(par = vars,
                            fn = OptimiseMechanicalAdvantage,
                            PA = PA, PO = PO, DO = DO, delta = delta, W = W,
                            target.ma = input$target.ma,
                            lower = c(15, vars["YO"]),
                            upper = c(25, vars["YO"] + 50), method = "L-BFGS-B")
      
      ma.final <- input$target.ma - optimised.ma$value
      L.final <- optimised.ma$par["L"]
      YO.final <- optimised.ma$par["YO"]
      
      # plot ma vs L (from 10 to 30) and YO (from min.YO to min.YO + 50)
      #     plot.new()
      plot1 <- ggplot() +
        ylab("Mechanical advantage") +
        stat_function(
          mapping = aes(x = YO),
          data = data.frame(YO = c(vars["YO"], vars["YO"] + 50)),
          fun = CalculateMechanicalAdvantage,
          args = list(L = L.final, PA = PA, PO = PO, DO = DO, delta = delta,
                      W = W),
          colour = "red") +
        geom_point(mapping = aes(x = x, y = y),
                   data = data.frame(x = YO.final, y = ma.final)) +
        geom_label(mapping = aes(x = x + 10, y = y,
                                 label = paste("MA =", round(ma.final, 1),
                                               "\nYO =", round(YO.final, 0),
                                               "\nL = ", round(L.final, 0))),
                   data = data.frame(x = YO.final, y = ma.final))
      
      plot2 <- ggplot() +
        ylab(NULL) +
        stat_function(
          mapping = aes(x = L),
          data = data.frame(L = c(15, 25)),
          fun = CalculateMechanicalAdvantage,
          args = list(YO = YO.final, PA = PA, PO = PO, DO = DO, delta = delta,
                      W = W),
          colour = "blue") +
        geom_point(mapping = aes(x = x, y = y),
                   data = data.frame(x = L.final, y = ma.final)) +
        geom_label(mapping = aes(x = x + 2, y = y,
                                 label = paste("MA =", round(ma.final, 1),
                                               "\nYO =", round(YO.final, 0),
                                               "\nL = ", round(L.final, 0))),
                   data = data.frame(x = L.final, y = ma.final))
      
      grid.arrange(plot1, plot2, ncol = 2)
    })
  }
)
  