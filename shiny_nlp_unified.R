# Course: Johns Hopkins Data Science Capstone
# Title: NLP Word Prediction
# Type: Shiny App (integrated UI and Server)
# Name: /shiny_nlp_unified.R
# Author: J. Shomaker
# Date: March, 2017

library(shiny)
source("~/Dropbox/JHDS/Capstone/final git/predict_functions.R")

gc()

ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("SwiftKey Next Word Prediction"),
  
  sidebarLayout(
    sidebarPanel(
      textInput(inputId="user_text",
                "Enter text:",
                value=""),
      
      actionButton("getButton", "Get Words"),
      
      helpText("Author: J Shomaker, r.03.2017")
      
    ),
    
    # Show up to five predicted next words
    mainPanel(
      h3(textOutput("predictions_caption")),
      textOutput(outputId="nlp_words"),
      
      h3(textOutput("response_caption")),
      textOutput(outputId="speed")
      
    )
  )  

  
))  

server <- shinyServer(function(input, output, session) {
  
  # predict words, only when button pressed
  words_update <- eventReactive(input$getButton, {
    predict_word(input$user_text)
    
  })
  
  # render caption and word prediction
  output$predictions_caption <- renderText({"Word Predictions"})
  
  output$nlp_words <- renderText({        
    
    # if user input is null, then "NA"      
    
    if (input$user_text != "") {
      words_update()
      
    }   else {
      "Error: No User Input"
      
    }
    
  })
  
})

runApp(shinyApp(ui = ui, server = server))
