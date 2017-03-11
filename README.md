## Overview

This repository comprises all of the relevant scripts and files associated with the Johns Hopkins Data Science Capstone class. The Capstone resulted in a Shiny app and final presentation that enables an end-user to enter a word or phrase and the app predicts the "next word" (actually 5 alternatives) based on natural language processing (NLP) algorithms built in the Capstone. The prediction algorithm was based on word frequency (actually phrase frequency, called ngrams) determined as a function of millions of U.S. Twitter posts, U.S. blog sentences, and U.S. news sentences. In short, I utilized an ngram backoff methodology, sampled the raw data at approximately 10%, and eliminated the sparse examples (freq = 1). Much of the Capstone effort was spent learning about NLP and text cleaning tools, libraries, and methodologies.

## File List

### Initial Cleansing & Report
nlp_report1.Rmd: first version of data download, sampling, cleansing, and exploration  
nlp_report1.Html: report output  
http://www.rpubs.com/jshomaker/capstone-milestone-1 : initial milestone report on RPubs  

### ngram Files
bigram_ctx.txt: 2-word ngram, sorted on frequency, eliminating sparser freq = 1 examples  
trigram_ctx.txt: 3-word ngram, sorted on frequency, eliminating sparser freq = 1 examples  
quadgram_ctx.txt: 4-word ngram, sorted on frequency, eliminating sparser freq = 1 examples  

### Prediction Models
predict_model_v1.Rmd: back-off model  
predict_model_v1a.Html: back-off model results using much larger ngrams (freq = 1 included)  
predict_model_v1a.Html: back-off model results using above ngram files without freq = 1 examples  
predict_function.R: back-off model repackaged as functions, called by Shiny app below  

### Shiny App Files (grouped under shiny_nlp_separate.Rproj)
ui.R, server.R: separate Shiny app files (more reliable structure to run from RStudio)  
shiny_nlp_unified.R: integrated ui.R and server.R script  
https://jshomaker1.shinyapps.io/nlp_predict2/ : URL to run the Shiny app  

### Other
profanity.txt: used for cleansing, both in the original model and for user input  

