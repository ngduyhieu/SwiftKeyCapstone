
library(shiny)
library(ggplot2)
library(plyr)


loadDataFrames <- function(){
    thres <- 0
    load('1gramsProcessedDataFrames_v3.Rdata')
    df_1grm <- df_total[df_total$freq > thres,]
    
    load('2gramsProcessedDataFrames_v3.Rdata')
    df_2grm <- df_total[df_total$freq > thres,]
    
    load('3gramsProcessedDataFrames_v3.Rdata')
    df_3grm <- df_total[df_total$freq > thres,]
    
    MyList<- list("grm1"=df_1grm, "grm2"=df_2grm, "grm3"=df_3grm) 
    #### Remove temporary variables
    rm(df_total)
    return(MyList)
}

plotfunc <- function(dataframe){
    if (length(dataframe$freq) >= 10) {
        p1 <- ggplot(dataframe[1:10,], aes(x = reorder(wrd, freq), y = freq)) 
    } else {
        p1 <- ggplot(dataframe[1:length(dataframe$freq),], aes(x = reorder(wrd, freq), y = freq))     
    }
    p1 <- p1 + stat_summary(fun.y = mean, geom="bar") 
    p1 <- p1 + labs(x = "Word", y="Probability") 
    p1 <- p1 + coord_cartesian()
    p1 <- p1 + coord_flip() 
    return(p1)
}


predictNextWord <- function(tmp_txt, MyList){
    
    ##################################################################################
    #### Load data
    df_1grm <- MyList$grm1
    df_2grm <- MyList$grm2
    df_3grm <- MyList$grm3
    
    #### Remove temporary variables
    rm(MyList)
    
    ##################################################################################
    #### Extract the trigrams and bigrams from the input phrase
    tmp_txt <- gsub("[[:punct:]]", "", tmp_txt) ## remove punctuation
    tmp_txt <- gsub("[[:digit:]]", "", tmp_txt) ## remove digits
    tmp_txt <- gsub("[^A-Za-z///' ]", "", tmp_txt) ## Remove special characters
    
    tmp_wrd <- unlist(strsplit(tmp_txt, split=" +")) ## split with any number of whitespace
    tmp_wrd <- tolower(tmp_wrd) ## lower all characters
    
    for_bgr <- tmp_wrd[length(tmp_wrd)]
    for_tgr <- paste(tmp_wrd[(length(tmp_wrd)-1):length(tmp_wrd)], collapse = " ")
    
    #### Remove temporary variables
    rm(tmp_wrd, tmp_txt)
    
    #################################################################################
    #### Results without removing stopwords
    wrd_total <- data.frame(wrd = c(), freq = c())
    
    #### Extracting potential words from Trigram
    wrd_3grm <- data.frame(wrd = c(), freq = c())
    df_tmp <- df_3grm[grepl(paste("^", for_tgr, ' ', sep = '', collapse = NULL), df_3grm[, 'trigrams']),]
    
    if (dim(df_tmp)[1] > 0) {
        df_tmp <- transform(df_tmp, trigrams = as.character(trigrams)) 
        df_tmp$allwrd <- strsplit(df_tmp[, 'trigrams'], split=" ")
        df_tmp$bgrtmp <- sapply(df_tmp$allwrd, function(x) paste(x[1:2], collapse = " "))
        df_tmp$wrd <- sapply(df_tmp$allwrd, function(x) x[3])

        df_tmp$freq_bgrtmp <- df_2grm[df_2grm$bigrams %in% df_tmp$bgrtmp, ]$freq    
        df_tmp <- transform(df_tmp, freq = freq/freq_bgrtmp) 
        df_tmp <- transform(df_tmp, freq = freq/sum(freq)) 
        wrd_3grm <- df_tmp[, c('wrd', 'freq')]
    }
    
    #### Extracting potential words from Bigram
    wrd_2grm <- data.frame(wrd = c(), freq = c())
    df_tmp <- df_2grm[grepl(paste("^", for_bgr, ' ', sep = '', collapse = NULL), df_2grm[, 'bigrams']),]
    
    if (dim(df_tmp)[1] > 0) {
        df_tmp <- transform(df_tmp, bigrams = as.character(bigrams)) 
        df_tmp$allwrd <- strsplit(df_tmp[, 'bigrams'], split=" ")
        df_tmp$ugrtmp <- sapply(df_tmp$allwrd, function(x) x[1])
        df_tmp$wrd <- sapply(df_tmp$allwrd, function(x) x[2])

        df_tmp$freq_ugrtmp <- df_1grm[df_1grm$unigrams %in% df_tmp$ugrtmp, ]$freq
        df_tmp <- transform(df_tmp, freq = freq/freq_ugrtmp) 
        df_tmp <- transform(df_tmp, freq = freq/sum(freq)) 
        wrd_2grm <- df_tmp[, c('wrd', 'freq')]
    }
    
    #### Extracting potential words from Unigram
    wrd_1grm <- data.frame(wrd = df_1grm$unigrams, freq = df_1grm$freq)
    wrd_1grm <- transform(wrd_1grm, freq = freq/sum(freq)) 
    
    #### Combine the frequency of the words
    wrd_3grm$freq <- 0.6*wrd_3grm$freq
    wrd_2grm$freq <- 0.3*wrd_2grm$freq
    wrd_1grm$freq <- 0.1*wrd_1grm$freq
    wrd_1grm <- wrd_1grm[wrd_1grm$freq > mean(wrd_1grm$freq), ]
    wrd_total <- rbind(wrd_total, wrd_3grm, wrd_2grm, wrd_1grm)
    wrd_total <- ddply(wrd_total, .(wrd), summarize, freq = sum(freq))
    
    #### Remove temporary variables
    rm(wrd_3grm, wrd_2grm, wrd_1grm, df_tmp)
    
    #### Order the words
    wrd_total <- wrd_total[order(wrd_total$freq,decreasing=TRUE),]
    
    ####
    return(wrd_total)
}


predictCurrentWord <- function(tmp_txt, MyList){
    ##################################################################################
    #### Load data
    df_1grm <- MyList$grm1
    df_2grm <- MyList$grm2
    df_3grm <- MyList$grm3
    
    #### Remove temporary variables
    rm(MyList)
    
    ##################################################################################
    #### Extract the trigrams and bigrams from the input phrase
    tmp_txt <- gsub("[[:punct:]]", "", tmp_txt) ## remove punctuation
    tmp_txt <- gsub("[[:digit:]]", "", tmp_txt) ## remove digits
    tmp_txt <- gsub("[^A-Za-z///' ]", "", tmp_txt) ## Remove special characters
    
    tmp_wrd <- unlist(strsplit(tmp_txt, split=" +")) ## split with any number of whitespace
    tmp_wrd <- tolower(tmp_wrd) ## lower all characters
    
    for_bgr <- tmp_wrd[length(tmp_wrd)]
    for_tgr <- paste(tmp_wrd[(length(tmp_wrd)-1):length(tmp_wrd)], collapse = " ")
    for_qgr <- paste(tmp_wrd[(length(tmp_wrd)-2):length(tmp_wrd)], collapse = " ")
    
    #### Remove temporary variables
    rm(tmp_txt, tmp_wrd)
    
    #################################################################################
    #### Results without removing stopwords
    crt_wrd <- data.frame(crtwrd = c(), freq = c())
    
    #### Extracting potential words from Trigram
    crtwrd_3grm <- data.frame(wrd = c(), freq = c())
    df_tmp <- df_3grm[grepl(paste("^", for_qgr, sep = '', collapse = NULL), df_3grm[, 'trigrams']),]
    
    if (dim(df_tmp)[1] > 0) {
        df_tmp <- transform(df_tmp, trigrams = as.character(trigrams)) 
        df_tmp$allwrd <- strsplit(df_tmp[, 'trigrams'], split=" ")
        df_tmp$bgrtmp <- sapply(df_tmp$allwrd, function(x) paste(x[1:2], collapse = " "))
        df_tmp$wrd <- sapply(df_tmp$allwrd, function(x) x[3])
        
        df_tmp$freq_bgrtmp <- df_2grm[df_2grm$bigrams %in% df_tmp$bgrtmp, ]$freq    
        df_tmp <- transform(df_tmp, freq = freq/freq_bgrtmp) 
        df_tmp <- transform(df_tmp, freq = freq/sum(freq)) 
        crtwrd_3grm <- df_tmp[, c('wrd', 'freq')]
    }
    
    #### Extracting potential words from Bigram
    crtwrd_2grm <- data.frame(wrd = c(), freq = c())
    df_tmp <- df_2grm[grepl(paste("^", for_tgr, sep = '', collapse = NULL), df_2grm[, 'bigrams']),]
    
    if (dim(df_tmp)[1] > 0) {
        df_tmp <- transform(df_tmp, bigrams = as.character(bigrams)) 
        df_tmp$allwrd <- strsplit(df_tmp[, 'bigrams'], split=" ")
        df_tmp$ugrtmp <- sapply(df_tmp$allwrd, function(x) x[1])
        df_tmp$wrd <- sapply(df_tmp$allwrd, function(x) x[2])
        
        df_tmp$freq_ugrtmp <- df_1grm[df_1grm$unigrams %in% df_tmp$ugrtmp, ]$freq
        df_tmp <- transform(df_tmp, freq = freq/freq_ugrtmp) 
        df_tmp <- transform(df_tmp, freq = freq/sum(freq)) 
        crtwrd_2grm <- df_tmp[, c('wrd', 'freq')]
    }
    
    #### Extracting potential words from Unigram
    crtwrd_1grm <- data.frame(wrd = c(), freq = c())
    df_tmp <- df_1grm[grepl(paste("^", for_bgr, sep = '', collapse = NULL), df_1grm[, 'unigrams']),]
    
    if (dim(df_tmp)[1] > 0) {
        df_tmp <- transform(df_tmp, unigrams = as.character(unigrams)) 
        crtwrd_1grm <- data.frame(wrd = df_tmp$unigrams, freq = df_tmp$freq)
        crtwrd_1grm <- transform(crtwrd_1grm, freq = freq/sum(freq)) 
    }
    
    #### Combine the frequency of the words
    crtwrd_3grm$freq <- 0.6*crtwrd_3grm$freq
    crtwrd_2grm$freq <- 0.3*crtwrd_2grm$freq
    crtwrd_1grm$freq <- 0.1*crtwrd_1grm$freq
    crtwrd_1grm <- crtwrd_1grm[crtwrd_1grm$freq > mean(crtwrd_1grm$freq), ]
    crt_wrd <- rbind(crt_wrd, crtwrd_3grm, crtwrd_2grm, crtwrd_1grm)
    crt_wrd <- ddply(crt_wrd, .(wrd), summarize, freq = sum(freq))
    
    #### Remove temporary variables
    rm(crtwrd_3grm, crtwrd_2grm, crtwrd_1grm, df_tmp)
    
    #### Order the words
    crt_wrd <- crt_wrd[order(crt_wrd$freq,decreasing=TRUE),]
    
    ####
    return(crt_wrd)
}



    
shinyServer(
    function(input, output) {
        MyList <- reactive({ loadDataFrames() })
        
        tmp_txt <- reactive({ as.character({input$text_input}) })
        
        
        ##############################################################################
        #### Predic the word you are typing now
        output$text1 <- renderText({
            paste("The word you want to type in this phrase:", tmp_txt())
        })
        
        crt_wrd <- reactive({ predictCurrentWord(tmp_txt(), MyList()) })
        
        #### Plot the probabilities of the ten most likely words
        p1 <- reactive({  plotfunc(crt_wrd()) })
        output$plot1 <- renderPlot({
            plot(p1())
        })
        
        output$plotinfo1 <- renderText({
            paste0("Some of the probabilities are: \n"
                   , crt_wrd()$wrd[1], ": ", round(crt_wrd()$freq[1], 3), "\n"
                   , crt_wrd()$wrd[2], ": ", round(crt_wrd()$freq[2], 3), "\n"
                   , crt_wrd()$wrd[3], ": ", round(crt_wrd()$freq[3], 3), "\n"
                   , crt_wrd()$wrd[4], ": ", round(crt_wrd()$freq[4], 3), "\n"
                   , crt_wrd()$wrd[5], ": ", round(crt_wrd()$freq[5], 3))
            
        })
        
        ##############################################################################
        #### Predic the next ten most likely words
        output$text2 <- renderText({
            paste("You want to predict the next word from the phrase:", tmp_txt())
        })
        
        wrd_total <- reactive({ predictNextWord(tmp_txt(), MyList()) })
        
        #### Plot the probabilities of the next ten most likely words
        p2 <- reactive({  plotfunc(wrd_total()) })
        output$plot2 <- renderPlot({
            plot(p2())
        })
        
        output$plotinfo2 <- renderText({
            paste0("Some of the probabilities are: \n"
                   , wrd_total()$wrd[1], ": ", round(wrd_total()$freq[1], 3), "\n"
                   , wrd_total()$wrd[2], ": ", round(wrd_total()$freq[2], 3), "\n"
                   , wrd_total()$wrd[3], ": ", round(wrd_total()$freq[3], 3), "\n"
                   , wrd_total()$wrd[4], ": ", round(wrd_total()$freq[4], 3), "\n"
                   , wrd_total()$wrd[5], ": ", round(wrd_total()$freq[5], 3))
            
        })
        
    }
)