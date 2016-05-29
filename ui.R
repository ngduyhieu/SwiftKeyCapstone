
library(shiny)
library(ggplot2)
library(plyr)

shinyUI(fluidPage(
  
    navbarPage(
        "Nguyen Duy Hieu",
        tabPanel("Coursera Data Science Capstone Project"),
        tabPanel("Predictive Word App")
    ),
    # titlePanel( "Coursera Data Science Capstone Project - Predictive Word App"),
    
    fluidRow(
        
        column(4, 
            fluidRow(wellPanel(
                h2("Documentation", style = "color:blue"),
                helpText('This app predicts: (1) the word you are typing, and (2) the next word you want to type given the input phrase.'),
                helpText('In this app, we implement an enhanced "Stupid Backoff" algorithm with trigrams, bigrams, and unigrams.'),
                helpText("The corpus is based on SwiftKey capstone dataset provided by Coursera.")
            )),
            
            fluidRow(wellPanel(
                h2("Input", style = "color:blue"),
                
                textInput(inputId="text_input", value = "I want to discuss about the New Y",
                          label = "Please type in a phrase. 
                          The app will predict: (1) the current typing word, and (2) the next most likely word."),
                
                submitButton('Submit'),
                br(),
                
                helpText("Note:", style = "color:red"), 
                helpText("The first part, i.e. predicting current word, 
                            runs so fast that it introduces errors without the submit button. 
                            As a result, dynamic prediction is not available. Sorry!")
            ))
        ),
    
        column(8, 
            
            fluidRow(wellPanel(
               h2("Most Likely Words That You Are Typing", style = "color:blue"),
               helpText('It might take ~ 5sec to load data and to process, please patiently wait .......'),
               
               h4(textOutput('text1'), style = "color:red"),
               br(),
               
               #             tableOutput("view"),
               #             br(),
               
               plotOutput("plot1", hover = "plot1_hover"),
               # plotOutput("plot1", click = "plot_click"),
               verbatimTextOutput("plotinfo1")
            )),
            
            fluidRow(wellPanel(
                h2("Next Ten Most Likely Words", style = "color:blue"),
                helpText('It might take ~ 5sec to load data and to process, please patiently wait .......'),
                
                h4(textOutput('text2'), style = "color:red"),
                br(),

                plotOutput("plot2", hover = "plot2_hover"),
                verbatimTextOutput("plotinfo2")
            ))
        )
    )
))