
shinyServer(function(input, output, session) {
  
  
  d <- reactiveValues()
  
  observe({
    d$data_for_plot <- tibble()
    d$data_for_table <- tibble()
    d$num_donors <- 0
    d$max_donor <- 0
    disableClearButtons(TRUE)
  })
  
  observeEvent(input$add_pair,{
    d$num_donors <- d$num_donors+1
    processInput()
    d$max_donor <- max(d$data_for_table$`Donor Pair`)
    disablePatientInput(TRUE)
    disableClearButtons(FALSE)
    
  })
  
  observeEvent(input$clear_selected,{
    
    if(length(input$table_rows_selected)>0){
        
        selected_inds <- input$table_rows_selected
        selected_pair <- d$data_for_table$`Donor Pair`[selected_inds]
        
        d$data_for_plot <- d$data_for_plot[-which(d$data_for_plot$`Donor Pair` %in% selected_pair),]
        d$data_for_table <- d$data_for_table[-selected_inds,]
        d$num_donors <- d$num_donors - length(selected_pair)
        
        
        if(d$num_donors>0){
          disablePatientInput(TRUE)
          d$max_donor <- max(d$data_for_table$`Donor Pair`)
          disableClearButtons(FALSE)
          
        } else {
          disablePatientInput(FALSE)
          d$max_donor <- 0
          disableClearButtons(TRUE)
        }
    }
    
  })
  
  observeEvent(input$clear_all,{
    d$data_for_plot <- tibble()
    d$data_for_table <- tibble()
    d$num_donors <- 0
    d$max_donor <- 0
    disablePatientInput(FALSE)
    disableClearButtons(TRUE)
  })

  disablePatientInput <- function(flag){
    
    if(flag){
      shinyjs::disable("disease")
      shinyjs::disable("dis_stage1")
      shinyjs::disable("dis_stage2")
      shinyjs::disable("dis_stage3")
      shinyjs::disable("hctcigp")
      shinyjs::disable("age")
      shinyjs::disable("rpt_cmv")
    } else {
      shinyjs::enable("disease")
      shinyjs::enable("dis_stage1")
      shinyjs::enable("dis_stage2")
      shinyjs::enable("dis_stage3")
      shinyjs::enable("hctcigp")
      shinyjs::enable("age")
      shinyjs::enable("rpt_cmv")
    }

  }
  disableClearButtons <- function(flag){
    
    if(flag){
      shinyjs::disable("clear_selected")
      shinyjs::disable("clear_all")
    } else {
      shinyjs::enable("clear_selected")
      shinyjs::enable("clear_all")
    }
    
  }
  
  

  ### save this as a tibble to load
  
  processInput <- reactive({

     donor_count <- d$num_donors
    
    ## disease stage

    if(input$disease=='AML'){
      dis_stage_input <- paste0(input$disease,', ',input$dis_stage1)
    } else if(input$disease=='ALL'){
      dis_stage_input <- paste0(input$disease,', ',input$dis_stage2)
    } else if(input$disease=='MDS'){
      dis_stage_input <- paste0(input$disease,', ',input$dis_stage3)
    } 
   
                            
    disease_stage <- switch(dis_stage_input, 
                            "AML, CR1"="1", 
                            "AML, CR2/CR3"="2", 
                            "AML, Advanced"="4", 
                            "ALL, CR1"="10", 
                            "ALL, CR2"="20", 
                            "ALL, CR3+"="30", 
                            "MDS, Early"="100", 
                            "MDS, Advanced"="200")
    
    if (input$dq_status != 'Missing'){
      data <- drdq_raw_base %>% filter(disstage == disease_stage)
    } else {
      data <- dr_raw_base %>% filter(disstage == disease_stage)
    }
    
    #=======================
    # covariates:
    
    ## bleader
    bleader_input <- input$match
    bleader <- switch(bleader_input, 
                      "Leader-matched"="0", 
                      "Leader-mismatched"="1")
    
    data <- data %>% filter(match_b == bleader)
    
    
    ## DRB1 and DQB1 matching
    drdq_input <- paste0(input$dr_status,'/',input$dq_status)
    if (input$dq_status != 'Missing'){
          drdq_input <- paste0(input$dr_status,'/',input$dq_status)
          drb1match <- switch(drdq_input,
                              "Match/Match"="0",
                              "Match/Mismatch"="1",
                              "Mismatch/Match"="2",
                              "Mismatch/Mismatch"="3"
          )
          data <- data %>% filter(drdq2 == drb1match)
    } else {
        ## DRB1 matching
        dr_input <- paste0(input$dr_status)
        drb1match <- switch(dr_input,
                            "Match"="0",
                            "Mismatch"="1"
        )
        data <- data %>% filter(drb1_gvh == drb1match)
    }
    ## DP TCE matching
    tce_input <- input$tce
    dp_tce <- switch(tce_input, 
                     "Matched or permissive"="2", 
                     "Non-permissive"="3", 
                     "Missing"="4"
    )
    
    data <- data %>% filter(tcegpd == dp_tce)
    
    ## comorbidity
    comorbidity <- switch(input$hctcigp, 
                          "1"="0", 
                          "2"="1", 
                          "3"="2",
                          "4"="3"
    )
    data <- data %>% filter(hctcigp == comorbidity)
    
    
    ## CMV 
    dnr_cmv_input <- input$dnr_cmv
    if( input$rpt_cmv =='Missing' | dnr_cmv_input =='Missing') {
      cmv <- 'Missing'
    } else {
      cmv <- paste0(input$rpt_cmv,'/',dnr_cmv_input)
    }
    
    cmv_test <- switch(cmv, 
                       "Positive/Positive"="0", 
                       "Positive/Negative"="1", 
                       "Negative/Positive"="2",
                       "Negative/Negative"="3",
                       "Missing"="4"
    )
    data <- data %>% filter(drcmvpr == cmv_test)
    
    
    ## age category
    age_cat <- switch(input$age, 
                      "1"="1", 
                      "2"="2", 
                      "3"="3",
                      "4"="4",
                      "5"="5",
                      "6"="6"
    )
    data <- data %>% filter(ragecat == age_cat)
    
    thisDonor <- d$max_donor + 1
    thisID <- input$did
    if(thisID ==''){
      thisID <- paste('Donor', thisDonor)
    }
    
    data$'Donor Pair' <- thisDonor
    data$'Donor Label' <- thisID
    
    
    
    #=======================
    # Probability at year 1:
    n12<- nrow(data %>% filter(intxrel<=12))
    n12
    
    prob <- round(data$surv[n12],2)
    up <- round(data$ciup[n12],2)
    low <- round(data$cilow[n12],2)
    
    # Probability at year 2:
    n24 <- nrow(data %>% filter(intxrel<=24))
    n24
    
    prob2 <- round(data$surv[n24],2)
    up2 <- round(data$ciup[n24],2)
    low2 <- round(data$cilow[n24],2)
    
    # Probability at year 3:
    n36 <- nrow(data %>% filter(intxrel<=36))
    n36
    
    prob3 <- round(data$surv[n36],2)
    up3 <- round(data$ciup[n36],2)
    low3 <- round(data$cilow[n36],2)
    
    data2 <- tibble('Donor Pair'= thisDonor,
                    'Donor Label'=thisID,
                    'HLA-B Leader' = bleader_input,
                    'HLA-DRB1/HLA-DQB1' = drdq_input,
                    'HLA-DPB1 TCE' = tce_input,
                    'Donor CMV' = dnr_cmv_input,
                    'Year 1 Probability'=prob, 
                    'Year 1  95% CI'=paste(low,"-", up), 
                    'Year 2 Probability'=prob2, 
                    'Year 2  95% CI'=paste(low2,"-", up2), 
                    'Year 3 Probability'=prob3, 
                    'Year 3  95% CI'=paste(low3,"-", up3))
    
    names(data)[2]="drb1dqb1_gvh"
    if (donor_count==1){
      d$data_for_table <- data2
      d$data_for_plot <- data
    } else {
      d$data_for_table <- rbind(d$data_for_table, data2)
      d$data_for_plot <- rbind(d$data_for_plot, data)
      
    }
    
  })
  
  
  #=======================
  # Plot:
  
  
  #========================
  # Its output type is a plot
  
  output$plots <- renderPlotly({

    if(d$num_donors==0){
      return(NULL)
    }
    
    
    plot_data <- d$data_for_plot
    
    plot_data$ci_text = paste(round(plot_data$cilow,2), '-', round(plot_data$ciup,2))
    #plot_data$name_text = paste('Pair:', plot_data$'Donor Pair','/',plot_data$'Donor Label')
    plot_data$name_text = plot_data$'Donor Label'
    
    plot_data$legend_group = paste0('group', plot_data$'Donor Pair')
    plot_data$sd <- plot_data$surv - plot_data$cilow
    cibmtr_colors = c('rgb(0, 121, 193)','rgb(234, 114, 0)','rgb(189, 204, 42)', 'rgb(246, 179, 49)', 'rgb(85, 86, 90)',
                      'rgb(0, 160, 221)','rgb(99, 167, 10)','rgb(138, 138, 141)')
    dp <- unique(plot_data$'Donor Pair')

    fig <- plot_ly() 
    for (i in 1:length(dp)){
      subdata <- plot_data %>% filter(`Donor Pair`==dp[i])
      fig <- fig %>% add_trace(type = 'scatter', mode = 'lines',data= subdata, x = ~intxrel, y = ~surv, text = ~ci_text, name = ~name_text, legendgroup = ~legend_group,
                               line = list(color = cibmtr_colors[i], width = 2),
                               hovertemplate = paste('<b>Months Post Transplant</b>: +%{x:f}',
                                                     '<br><b>Disease-free Survival</b>: %{y:.2f}',
                                                     '<br><b>95% CI</b>: %{text}')) 
      fig <- fig %>% add_trace(type = 'scatter', mode = 'lines',data= subdata, x = ~intxrel, y = ~cilow, name = '95% CI',  line = list(color = cibmtr_colors[i], width = 1, dash = 'dot'), hoverinfo="none", legendgroup = ~legend_group, showlegend = FALSE) 
      fig <- fig %>% add_trace(type = 'scatter', mode = 'lines',data= subdata, x = ~intxrel, y = ~ciup, name = '95% CI',  line = list(color = cibmtr_colors[i], width = 1, dash = 'dot'), hoverinfo="none", legendgroup = ~legend_group, showlegend = FALSE) 
    }
    fig <- fig %>% layout(title = list(text="Predicted probability of disease-free survival after haploidentical transplant", 
                                       font=list(size=20)),
                          margin = 10,
                          xaxis = list(title = list(text="Post-transplant time (month)",
                                                    font=list(size=14)), 
                                       zeroline = TRUE,
                                       showLine = TRUE,
                                       range= c(0,36),
                                       ticktext = list("3", "6", "9", "12", "15", "18", "21", "24","27","30","33","36"), 
                                       tickvals = list(3,6,9,12,15,18,21,24,27,30,33,36),
                                       tickmode = "array",
                                       tickfont=list(size=12)
                                       ),
                          yaxis = list (title = list(text="Probability",
                                        font=list(size=14)),
                                        zeroline = TRUE,
                                        dtick = 0.1,
                                        tick0=0.1,
                                        range=c(0,1),
                                        tickfont=list(size=12)
                                        )
    ) %>% config(modeBarButtonsToRemove = list('zoom2d', 'pan2d', 'select2d', 'lasso2d', 
                                               'zoomIn2d', 'zoomOut2d', 'autoScale2d', 
                                               'hoverClosestCartesian', 'hoverCompareCartesian', 
                                               'resetScale2d','toggleHover', 'resetViews', 
                                               'toggleSpikelines'))
 
    fig
  })
  
  output$plotfootnote <- renderUI({
    if(d$num_donors==0){
      return('')
    }
    
    p('Dashed lines in the plot show the 95% confidence intervals for the corresponding colored lines.', id='plot-footnote')
    
  })

  output$table <- DT::renderDataTable({
    
    if(d$num_donors==0){
      return(NULL)
    }

    df <- d$data_for_table
    file_label <- paste0(gsub(pattern = ' ',replacement = '',input$pat_label),'_DFS_Predictions')
    
    DT::datatable(df, 
                  extensions = 'Buttons',
                  options = list(dom = 'tB', 
                                 columnDefs = list(list('orderable' = FALSE, targets = c(2,3,4,5,7,9,11))
                                                 #  list(width = '100px', targets = c(7, 9,11))
                                                   ),
                                 buttons = list(list('extend'='copy', 'text'='Copy to clipboard'),
                                           list('extend'='csv', 'text'='Save as CSV', filename=file_label),
                                           list('extend'='excel', 'text'='Save as Excel', filename=file_label))), 
                  rownames = FALSE)
    
  }, server = TRUE)
  
  
  
})