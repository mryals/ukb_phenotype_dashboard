#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste('ukb_data_', Sys.Date(), '.csv', sep='')
        },
        content = function(con) {
            data <- rbindlist(EXPORT_DATA, fill = TRUE) %>%
                mutate(name = paste0(make.names(name),".", instance, ".", array)) %>%
                pivot_wider(id_cols = c(eid), #array 
                            names_from = name, 
                            values_from = value)
            
            fwrite(data, con)
        }
    )
    
    output$dict <- DT::renderDT(dict %>% 
                                    dplyr::select(-Path, -Category, -Notes, -Link) %>%
                                    mutate(FieldID = as.factor(FieldID)), 
                                options = list(pageLength = 5,
                                               autoWidth = TRUE,
                                               scrollX = TRUE,
                                               searchHighlight = TRUE),
                                filter = list(
                                    position = 'top', clear = TRUE
                                ),
                                selection = 'single'
    )
    
    
    
    output$info = renderPrint({
        idx = input$dict_row_last_clicked
        if (length(idx)) {
            dat <- dict[idx, ,drop = F]
            cat(glue("Field ID: {dat$FieldID}\n\n"))
            cat(glue("Field Name: {dat$Field}\n\n"))
            cat(glue("#Participants: {dat$Participants}\n\n"))
            cat(glue("#Items: {dat$Items}\n\n"))
            cat(glue("Stability: {dat$Stability}\n\n"))
            cat(glue("Value Type: {dat$ValueType}\n\n"))
            cat(glue("Strata: {dat$Strata}\n\n"))
            cat(glue("Sexed: {dat$Sexed}\n\n"))
            cat(glue("#Instances: {dat$Instances}\n\n"))
            cat(glue("#Array: {dat$Array}\n\n"))
        }
    })
    
    dataInput <- reactive({
        req(input$dict_row_last_clicked)
        idx = input$dict_row_last_clicked
        field_id <- as.numeric(dict[idx, "FieldID"])
        get_pheno_data(field_id, decode = TRUE) %>% mutate(array = as.numeric(array))
    })
    
    # exportInput <- reactive({
    #     rbindlist(EXPORT_DATA, fill = TRUE)
    # })
    # 
    # output$data_export <- DT::renderDT(exportInput() %>% 
    #                                        pivot_wider(id_cols = eid, 
    #                                                    names_from = name, 
    #                                                    values_from = value), 
    #                                    options = list(pageLength = 5,
    #                                                   autoWidth = TRUE,
    #                                                   scrollX = TRUE,
    #                                                   searchHighlight = TRUE),
    #                                    filter = list(
    #                                        position = 'top', clear = TRUE
    #                                    ),
    #                                    selection = 'nono')
    
    # observeEvent(input$dict_row_last_clicked, {
    #     output$dat <- DT::renderDT(dataInput(),
    #                                options = list(pageLength = 5,
    #                                               autoWidth = TRUE,
    #                                               scrollX = TRUE,
    #                                               searchHighlight = TRUE),
    #                                filter = list(
    #                                    position = 'top', clear = TRUE
    #                                ),
    #                                selection = 'none'
    #     )
    # })
    
    observeEvent(input$dict_row_last_clicked, {
        idx = input$dict_row_last_clicked
        dat <- dict[idx, ,drop = F]
        vtype <- as.character(dat$ValueType)
        output$plot <- renderPlot({
            if (is.null(input$instances_selected) & is.null(input$array_max_selected)) {
                p <- summary_plot(dataInput(), 
                                  vtype)
            } else if (is.null(input$instances_selected)) {
                p <- summary_plot(dataInput() %>% 
                                      filter(array <= input$array_max_selected), 
                                  vtype)
            } else if (is.null(input$array_max_selected)) {
                p <- summary_plot(dataInput() %>% 
                                      filter(instance %in% input$instances_selected), 
                                  vtype)
            } else {
                p <- summary_plot(dataInput() %>% 
                                      filter(instance %in% input$instances_selected, 
                                             array <= input$array_max_selected), 
                                  vtype)
            }
            
            p
        })
    })
    
    observeEvent(input$dict_row_last_clicked, {
        output$button <- renderUI({
            actionButton("click_add_button", "Add to data bucket", class="btn-success",
                         icon = icon("refresh"))
        })
    })
    
    observeEvent(input$click_add_button, {
        idx = input$dict_row_last_clicked
        dat <- dict[idx, ,drop = F]
        FieldID <- as.numeric(dat$FieldID)
        if (is.null(input$instances_selected) & is.null(input$array_max_selected)) {
            EXPORT_DATA[[FieldID]] <<- dataInput()
        } else if (is.null(input$instances_selected)) {
            EXPORT_DATA[[FieldID]] <<- dataInput() %>% 
                filter(array <= input$array_max_selected) #%>%
                # mutate(name = paste(name, array, sep = " "))
        } else if (is.null(input$array_max_selected)) {
            EXPORT_DATA[[FieldID]] <<- dataInput() %>% 
                filter(instance %in% input$instances_selected)
        } else {
            EXPORT_DATA[[FieldID]] <<- dataInput() %>% 
                filter(instance %in% input$instances_selected, 
                       array <= input$array_max_selected) #%>%
                # mutate(name = paste(name, array, sep = " "))
        }
    })
    
    output$select_instance <- renderUI({
        req(length(unique(dataInput()$instance))>1)
        instances_idx <- as.numeric(unique(dataInput()$instance)) + 1
        instances_choices <- instances[instances_idx]
        checkboxGroupInput("instances_selected", label = h4("Select instance(s)"), 
                           choices = instances_choices,
                           inline = TRUE,
                           selected = instances_choices[1])
    })
    
    output$select_array <- renderUI({
        req(max(as.numeric(unique(dataInput()$array)))>1)
        array_max <- max(as.numeric(unique(dataInput()$array)))
        array_min <- min(as.numeric(unique(dataInput()$array)))
        sliderInput("array_max_selected", label = h4("Select maximum array"), min = array_min, 
                    max = array_max, value = array_max)
    })
    
    observeEvent(input$click_add_button, {
        idx = input$dict_row_last_clicked
        dat <- dict[idx, ,drop = F]
        FieldID <- as.numeric(dat$FieldID)
        session$sendCustomMessage(type = 'testmessage',
                                  message = glue("Add data [field id: {FieldID}] to the bucket"))
    })
    
    output$progressBox <- renderInfoBox({
        input$click_add_button
        infoBox(
            paste0(sum(!sapply(EXPORT_DATA, is.null)), " Field(s)"), "Added to Bucket", icon = icon("list"),
            color = "purple"
        )
    })
    
    output$select_lkp <- renderUI({
        selectInput(
            inputId = "lkp_sheet_id",
            label = "Lookup Sheet",
            selected =  "icd10_lkp",
            choices = lkps_sheets)
    })
    
    output$select_mapping <- renderUI({
        selectInput(
            inputId = "mapping_sheet_id",
            label = "Mapping Sheet",
            choices = maps_sheets)
    })
    
    MappingDataInput <- reactive({
        req(input$mapping_sheet_id)
        # readxl::read_excel(file.path("www", "all_lkps_maps_v2.xlsx"), sheet = input$mapping_sheet_id)
        maps_data[[input$mapping_sheet_id]]
    })
    
    lkpDataInput <- reactive({
        req(input$lkp_sheet_id)
        # readxl::read_excel(file.path("www", "all_lkps_maps_v2.xlsx"), sheet = input$lkp_sheet_id)
        lkps_data[[input$lkp_sheet_id]]
    })
    
    observeEvent(input$mapping_sheet_id, {
        output$map_sheet_DT <- DT::renderDT(MappingDataInput(),
                                            options = list(pageLength = 5,
                                                           autoWidth = FALSE,
                                                           scrollX = TRUE,
                                                           searchHighlight = TRUE),
                                            filter = list(
                                                position = 'top', clear = TRUE
                                            ),
                                            selection = 'none'
        )
    })
    
    observeEvent(input$lkp_sheet_id, {
        output$lkp_sheet_DT <- DT::renderDT(lkpDataInput(),
                                            options = list(pageLength = 5,
                                                           autoWidth = FALSE,
                                                           scrollX = TRUE,
                                                           searchHighlight = TRUE),
                                            filter = list(
                                                position = 'top', clear = TRUE
                                            ),
                                            selection = 'none'
        )
    })
    
    # output$select_icd10 <- renderUI({
    #     selectInput(
    #         inputId = "icd10_selected",
    #         label = "Select one ICD10 code",
    #         choices = lkps_data[["icd10_lkp"]]$ALT_CODE)
    # })
    
    # swith to server-side selectize
    updateSelectizeInput(session, 'icd10_selected', 
                         choices = lkps_data[["icd10_lkp"]]$ALT_CODE, 
                         server = TRUE)
    
    ICD10MapsInput <- reactive({
        req(input$icd10_selected)
        find_icd10_maps(input$icd10_selected)
    })
    
    observeEvent(input$icd10_selected, {
        output$icd10_maps_DT <- DT::renderDT(ICD10MapsInput(),
                                            options = list(pageLength = 10,
                                                           autoWidth = FALSE,
                                                           scrollX = TRUE,
                                                           searchHighlight = TRUE),
                                            filter = list(
                                                position = 'top', clear = TRUE
                                            ),
                                            selection = 'none'
        )
    })
})
