---
title       : Predictive Word App
subtitle    : Coursera Data Science Capstone Project
author      : Hieu Duy Nguyen (Hill)
job         : 27th May 2016 
framework   : io2012     # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : [mathjax]            # {mathjax, quiz, bootstrap}
ext_widgets : {rCharts: [libraries/nvd3]}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
---

## Overview of a Predictive Word App

<ol>
<li> Two objectives: </li>
    <ul>
        <li> Predict which word the user is typing now.  </li>
        <li> Predict which word the user wants to type next.  </li>
    </ul>
<li> Our approach: n-grams and weighted back-off model 
    <ul>
        <li> Given a corpus (from SwiftKey), we extract three datasets from 30k randomly selected tweets, 30k blog posts, and 30k news (anymore and shinyapps.io will crash):  </li>
                <ul>
                    <li> Unigrams: 95158 objects with their probabilities
                    <li> Bigrams: 1001663 objects with their probabilities
                    <li> Trigrams: 2047245 objects with their probabilities
                </ul>
        <li> Weighted back off model for next word prediction (problem 2): <big> $w^i$ </big> is the word we want. Then its probability is: $P(w^i|w^{i-1}_{i-2}) = \alpha_1 \frac{P(w^{i}_{i-2})}{P(w^{i-1}_{i-2})} + \alpha_2 \frac{P(w^{i}_{i-1})}{P(w^{i-1})} + \alpha_3 P(w^i)$   </li>
        <li> Weighted back off model for current word prediction (problem 1): similarly defined. </li>
    </ul>

--- .class #id 

## The proposed scheme flowchart

<center> <img src="PredictiveWordFlowchart.jpg" alt="PredictiveWordFlowchart" height="500" width="800"> </center>

--- .class #id

## Type in the phrase and get the prediction!

<ol>
<li> The app link is here: https://ngduyhieu.shinyapps.io/CapStone_ShinyApp </li>
<li> Example: type in "I like to visit San Fran" </li>
<li> Example: type in "I love you so" </li>

<center> <img src="MostLikelyCurrentAndNextWord.jpg" alt="CurrentAndNextWord" height="400" width="900"> </center>


--- .class #id 
<div align="center"; style="margin:200px 0 0 0;">
<font color="red"; size="13"> Thank you </font>
</br> </br>
<font color="blue"> Please support my world-changing :) app </font>
</div>

