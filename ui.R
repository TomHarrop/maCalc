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
                  step = 0.1),
      sliderInput("yo",
                  "Minimum yoke height",
                  min = 50,
                  max = 300,
                  value = 150,
                  step = 1),
      sliderInput("po",
                  "Fork width at canti studs",
                  min = 10,
                  max = 150,
                  value = 80,
                  step = 1),
      sliderInput("do",
                  "Vertical distance from canti studs to centre of rim",
                  min = 20,
                  max = 40,
                  value = 30,
                  step = 1),
      sliderInput("w",
                  "Rim width",
                  min = 15,
                  max = 50,
                  value = 30,
                  step = 0.1),
      sliderInput("pa",
                  "Cantilever arm length",
                  min = 50,
                  max = 100,
                  value = 65,
                  step = 1),
      sliderInput("delta",
                  "Angle between canti arm and brake pad attachment arm",
                  min = 0,
                  max = 90,
                  value = 20.5,
                  step = 0.1)),

    mainPanel(
      plotOutput("ma.plot")
    )
  )
)
