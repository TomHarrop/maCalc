library(shiny)

fluidPage(
  titlePanel("Calculate mechanical advantage", windowTitle = "MA Calculator"),
  
  sidebarLayout(
    # inputs go in the sidebar in sliders
    sidebarPanel(
      sliderInput("target.ma",
                  "Desired mechanical advantage",
                  min = 1,
                  max = 3,
                  value = 2.5,
                  round = 1,
                  step = 0.1)
    ),
    
    # plot goes in the main panel
    mainPanel(
      plotOutput("ma.plot")
    )
    
    
  )
)