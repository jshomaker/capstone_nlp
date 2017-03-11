## Capstone-Predict3
## Author: John Shomaker
## Date: 3/2017

## SwiftKey word prediction model, constructed as part of the Johns Hopkins 
## Data Science Capstone program. The Capstone focuses on the data science of 
## natural language processing ("NLP"), leveraging the entire course's
## methodologies and learnings to disect the SwiftKey text dataset. SwiftKey
## is in the business of mobile applications and technologies, one of which is
## a feature that predicts type-ahead for mobile texters. Model leverages 
## [Katz-Backoff](https://en.wikipedia.org/wiki/Katz%27s_back-off_model)
## (adaptation of [Markov Chains](https://en.wikipedia.org/wiki/Markov_chain)) 
## method of predicting the 'next word', if a user provides an input of one or 
## more words. The input is cleansed consistent with the original datasets of 
## news, blogs, and Twitter. And depending on the length of the input n, an 
## n+1-gram is tested for matches. In short, the input is compared against the 
## left n words of the n-gram. If matches aren't found, the input eliminates 
## the left most word, and backs off to compare against the next n-gram 
## (i.e., ideally start with the 4-gram, then try the 3-gram, and then try the 2-gram).

## Load packages & libraries

## install.packages("tm") # text libraries
## install.packages("qdap")
## install.packages("SnowballC") # shortcut for stemming in corpus
## install.packages("qdapRegex") # shortcut to clean up twitter formats
## install.packages("plyr") # dataset manipulation
## install.packages("stringr") # certain text manipulation

library(tm)
library(qdap)
library(qdapRegex)
library(SnowballC)
library(plyr)
library(stringr)

# setwd("/Users/john/DropBox/JHDS/Capstone/final_git/shiny_nlp_separate")

## Load n-gram frequency tables (for speed, exclude records where frequ=1)

bi <- read.table("bigram_ctx.txt", header = TRUE)
tri <- read.table("trigram_ctx.txt", header = TRUE)
quad <- read.table("quadgram_ctx.txt", header = TRUE)

## Cleanse user input (mirrors cleansing steps for original n-grams

cleanse_input <- function(input) {
  
    ## Cleanse the US samples for non-ASCII encoding
  
    encodingASCII <- function(input, print=FALSE){
        input <- lapply(input, function(row) iconv(row, "latin1", "ASCII", sub="")) 
        return(unlist(input))
    }
  
    input = encodingASCII(paste(input))
  
    ## Remove Twitter retweets, handles, http links, emoticons, hash tags, and URLs 
  
    input <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", input)
    input <- gsub("@\\w+", "", input)
    input <- gsub("http\\w+", "", input)
    input <- rm_emoticon(input)
    input <- rm_hash(input)
    input <- rm_url(input)
  
    ## Convert input to a corpus and use tm to further cleanse
  
    input_corpus <- VCorpus(VectorSource(input))
    input_corpus <- tm_map(input_corpus, content_transformer(tolower), lazy = TRUE)
    input_corpus <- tm_map(input_corpus, removePunctuation, lazy = TRUE)
    input_corpus <- tm_map(input_corpus, removeNumbers, lazy = TRUE)
  
    # Eliminate one-letter non-words, stopwords, and stemming
  
    cust_stop <- c("josh", "b", "c", "d", "e", "f", "g", "h", "j", "k", "l", "m", 
                 "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")
  
    input_corpus <- tm_map(input_corpus, removeWords, c(cust_stop), lazy = TRUE)

    # Remove profanity and strip white space
  
    profanity_file <- file("profanity.txt", "r")
    profanity_terms <- read.table(profanity_file, stringsAsFactors=F)
    close(profanity_file)
    profanity_filter <- c(profanity_terms[,1])
    profanity_filter <- unique(profanity_filter)
    input_corpus <- tm_map(input_corpus, removeWords, profanity_filter, lazy = TRUE)
  
    input_corpus <- tm_map(input_corpus, stripWhitespace, lazy = TRUE)
    input_corpus <- tm_map(input_corpus, PlainTextDocument, lazy = TRUE)
  
    # Convert corpus back into text vector

    input <- data.frame(text=unlist(sapply(input_corpus, `[`, "content")), stringsAsFactors=F)
    input <- as.character(input)
  
}

## Predict words using Katz-Backoff (simple Markov Chain)
## This model is a basic IF:THEN "lookup" algorithm. If the user inputs a string
## of "go to the" (word length = 3), we seek to match this input against the left
## 3 words of the 4-gram frequency file. If matches are found, it prints the 3 
## matches with the highest frequency. If no matches are found, the left-most word
## of the input is parsed off, leaving "to the", which is looked up against the 
## left-most two words of the 3-gram frequency file, and so on. If no match is 
## found after testing the 2-gram, "NAs" are returned. The theory is that the
## longer the phrase and the highest-order of n-gram matched, the higher the 
## relevance (or probability of being a correct prediction for the user). For 
## instance, "go to the" as input, matching to "store" is more relevant than "the"
## matching to "pig". The words "go to" add more context, so a match with a 4-gram
## is considered more relevant than a single-word input matching to a 2-gram.

predict_word <- function(input) { 
  
    clean <- cleanse_input(input)  
  
    ## Count length of initial input, limit to 3 words (i.e., accommodate a 4-gram)
  
    clean_len <- str_count(clean, '\\w+') # input words
    answer <- data.frame()
  
    for (val in 1:3) {
    
    ## Attempts a match with 4-gram lookup, then 3-gram, then 2-gram
    ## Selects up to 5 potential matching words
    ## If no matches across all n-grams, then response is "NA"
    ## Positive match breaks the loop
    
        if (clean_len >= 3) { 
            quad_search <- paste("^", word(clean, -3, -1), " ", sep="")
            quad_find <- quad[grep(quad_search, quad$ngram),] # find matches
      
            if (nrow(quad_find) != 0) { 
                quad_find <- quad_find[1:5,] # select top 5 (highest prob)
                quad_find$ngram <- word(quad_find$ngram, -1) # select last word
                answer <- quad_find$ngram
                break
            
            }   else clean_len <- 2
          
        }
    
        if (clean_len == 2) { 
            tri_search <- paste("^", word(clean, -2, -1), " ", sep="")
            tri_find <- tri[grep(tri_search, tri$ngram),] # find matches
      
            if (nrow(tri_find) != 0) { 
                tri_find <- tri_find[1:5,] # select top 5 (highest prob)
                tri_find$ngram <- word(tri_find$ngram, -1) # select last word
                answer <- tri_find$ngram
                break
            
            }   else clean_len <- 1
    
        }
    
        if (clean_len == 1) { 
            bi_search <- paste("^", word(clean, -1), " ", sep="") 
            bi_find <- bi[grep(bi_search, bi$ngram),] # find matches
      
            if (nrow(bi_find) != 0) { 
                bi_find <- bi_find[1:5,] # select top 5 (highest prob)
                bi_find$ngram <- word(bi_find$ngram, -1) # select last word
                answer <- bi_find$ngram
                break
            
            }   else 
                    answer <- "NA"
    
        }
  
    }    
    
    answer <- paste(answer, collapse="   |   ")
    
}    

## Example inputs

## predict_word("The guy in front of me just bought a pound of bacon, a bouquet, and a case of")
## predict_word("take me to the church")

