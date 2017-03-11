# Course: Johns Hopkins Data Science Capstone
# Title: NLP Word Prediction
# Type: Shiny Server
# Name: /shiny_nlp_separate/server.R
# Author: J. Shomaker
# Date: March, 2017

library(shiny)
# setwd("/Users/john/Dropbox/JHDS/Capstone/final git/shiny_nlp_separate")

source("predict_functions.R")

shinyServer(function(input, output, session) {
  
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