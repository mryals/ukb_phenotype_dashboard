#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
## ui.R ##
library(shiny)
library(DT)
library(glue)
library(shinydashboard)

source("global.R")

ui <- dashboardPage(skin = "purple",
    dashboardHeader(title = "UKB Phenotypes Dashboard",
                    titleWidth = 300),
    dashboardSidebar(width = 300,
                     sidebarMenu(
                         id = "tabs",
                         menuItem("Phenotype data explore", tabName = "dashboard", icon = icon("dashboard")),
                         menuItem("Primarycare codings explore", tabName = "mapping", icon = icon("th"),
                                  menuSubItem("Find mapping rules", tabName = "icd10map", icon = icon("search", lib = "glyphicon")),
                                  menuSubItem("Look up table explore", tabName = "lkptab", icon = icon("eye-open", lib = "glyphicon")),
                                  menuSubItem("Map table explore", tabName = "maptab", icon = icon("globe", lib = "glyphicon")))
                     )
    ),
    dashboardBody(
        tags$head(tags$script(src = "message-handler.js")),
        tags$head(tags$style(".butt{background-color:#add8e6;} .butt{color: #337ab7;}")),
        # Boxes need to be put in a row (or column)
        tags$style(HTML(".main-sidebar { font-size: 16px!important; }
                   .treeview-menu>li>a { font-size: 16px!important; }")),
        tabItems(
            # First tab content
            tabItem(tabName = "dashboard",
                    fluidRow(
                        box(DT::DTOutput("dict"), width = 12),
                    ),
                    fluidRow(
                        box(title = "Basic info of the selected field", 
                            status = "info", 
                            verbatimTextOutput('info'),                            
                            uiOutput("select_instance"),
                            uiOutput("select_array"),
                            uiOutput("button")
                        ),
                        
                        box(
                            title = "Plot",
                            
                            # DT::DTOutput("dat")
                            plotOutput("plot")
                        )
                    ),
                    fluidRow(
                        downloadButton('downloadData', 'Download the data', class = "butt"),
                        infoBoxOutput("progressBox")
                    )
                    
            ),
            tabItem(tabName = "icd10map",
                    fluidRow(
                        box(title = "Please select one ICD 10 code", 
                            # uiOutput("select_icd10")
                            selectInput(
                                inputId = "icd10_selected",
                                label = "Select one ICD10 code",
                                choices = NULL)
                        )
                    ),
                    fluidRow(
                        box(DT::DTOutput("icd10_maps_DT"), width = 12),
                    )
            ),
            tabItem(tabName = "lkptab",
                    fluidRow(
                        box(title = "Please select one lookup table", uiOutput("select_lkp")),
                        box(DT::DTOutput("lkp_sheet_DT"), width = 12)
                    )

            ),
            tabItem(tabName = "maptab",
                    fluidRow(
                        box(title = "Please select one mapping table", uiOutput("select_mapping")),
                        box(DT::DTOutput("map_sheet_DT"), width = 12)
                    )
                    
            )
        )
    )
)

