# ui.R
# Coursera DDP project final version

# Title: Is strikeout rate associated with player's homerun hitting ability?
# Author: Yosuke Ishizaka

library(shiny)
top100 <- readRDS("top100.rds")

shinyUI(fluidPage(
        titlePanel('Career Homerun Total and Strikeout Rate of Top Homerun Hitters in MLB History (~2014)'),
        sidebarLayout(
                # Select Box are used to have user select a player from top 100 homerun hitters in history
                # Default choice for player 1 is Barry Bonds and player 2 is Babe Ruth
                sidebarPanel(
                        selectInput("player1", label=h3('Select a player'),
                                    choices = top100$playerName,
                                    selected = "Barry Bonds"),
                        selectInput("player2", label=h3('Select another player'),
                                    choices = top100$playerName,
                                    selected = "Babe Ruth")
                ),
                mainPanel(
                        h4('You have selected'),
                        verbatimTextOutput("player1"),
                        tableOutput("table1"),
                        h4('You have selected'),
                        verbatimTextOutput("player2"),
                        tableOutput("table2"),
                        plotOutput("plot")
                )
                
        )
))