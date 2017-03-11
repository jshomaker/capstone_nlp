# Course: Johns Hopkins Data Science Capstone
# Title: NLP Word Prediction
# Type: Shiny UI
# Name: /shiny_nlp_separate/ui.R
# Author: J. Shomaker
# Date: March, 2017


library(shiny)
# setwd("/Users/john/Dropbox/JHDS/Capstone/final git/shiny_nlp_separate")

shinyUI(fluidPage(
  
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