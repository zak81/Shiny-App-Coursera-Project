# server.R
# Coursera DDP project final version

# Title: History's greatest homerun hitters and their strikeout rate
# Author: Yosuke Ishizaka


# Load required packages
library(shiny)
suppressMessages(library(dplyr))
library(ggplot2)
library(Lahman)

# Load Batting and Master data from Lahman database and covert them to local data frames
data(Batting)
data(Master)
batting <- tbl_df(Batting)
master <- tbl_df(Master)

# Join two data frames and create a new column called playerName, which stores player's full name
batting_new <- inner_join(batting, master)
batting_new$playerName <- with(batting_new, paste(nameFirst, nameLast, sep = " "))

# Data cleaning step was necessary, Sacrifice Flies were not officially recorded in some years
batting_new$SF[is.na(batting_new$SF)] <- 0

# The following code creates a new data frame,
# First, new variable PA (Plate Appearances) is created,
# Then, group by player and sum yearly stats so that each player's total stats are shown,
# Then, create a new variable KRate (Strikeout Percentage),
# Next, select the variables I want displayed,
# Finally, sort by total number of homeruns
player_stats <- batting_new %>%
        mutate(PA = AB+BB+HBP+SF+SH) %>%
        group_by(playerID, playerName) %>%
        summarise_each(funs(sum), HR, SO, PA) %>%
        mutate(KRate = SO/PA) %>%
        select(playerName, HR, SO, PA, KRate) %>%
        ungroup() %>%
        arrange(desc(HR))

# Convert Plate Appearances variable from num to integer variable        
player_stats$PA <- as.integer(player_stats$PA)

# Create a variable to show only the top 100 homerun hitters in history
top100 <- player_stats %>%
        select(playerName, HR, SO, PA, KRate) %>%
        head(100)

# Save it in RDS file so that ui.R can use the data frame
saveRDS(top100, file="top100.rds")

# Create a scatter plot to show Strikeout Percentage vs Total Homeruns for all MLB players
g <- ggplot(player_stats, aes(KRate, HR)) + labs(list(x = "K%", y = "Total Homeruns"))

# Code inside shinyServer function does the following:
# First, users can select up to 2 players from a selection of top 100 homerun hitters,
# Then, it outputs player names to a main panel,
# Then, it outputs a table with player stats for the selected players,
# Once the players are selected the app will automatically plot a scatter plot

shinyServer(function(input, output) {
        datasetInput1 <- reactive({ input$player1 })
        output$player1 <- renderPrint({ datasetInput1() })
        output$table1 <- renderTable({ subset(top100, player_stats$playerName==input$player1) })
        datasetInput2 <- reactive({ input$player2 })
        output$player2 <- renderPrint({ datasetInput2() })
        output$table2 <- renderTable({ subset(top100, player_stats$playerName==input$player2) })
        output$plot <- renderPlot({
                g + geom_point(colour = ifelse(player_stats$playerName==input$player1,"red",
                ifelse(player_stats$playerName==input$player2, "blue", "black")),
                alpha = ifelse(player_stats$playerName==input$player1 | player_stats$playerName==input$player2, 0.5, 0.2),
                size = ifelse(player_stats$playerName==input$player1 | player_stats$playerName==input$player2, 5, 4)) +
                geom_text(data=subset(player_stats, playerName==datasetInput1()), label = datasetInput1(), hjust = -0.1) +
                geom_text(data=subset(player_stats, playerName==datasetInput2()), label = datasetInput2(), hjust = -0.1)
                })
})






