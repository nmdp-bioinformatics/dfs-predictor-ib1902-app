shinyUI(

    fluidPage(

    tags$head(includeHTML(("www/google-analytics.html"))),
      
    #== App title ----
    titlePanel(title = NULL, windowTitle = "Disease-Free Survival Calculator"),
    
    ## create header bar
    h1("A predictor for probability of disease-free survival after haploidentical transplant", 
       id='header-bar'),
    
    navbarPage('Select:',selected = 1,
    
    ### introduction page           
    tabPanel('Introduction',value=1,
             
             shinyjs::useShinyjs(),
             HTML(version_text),
             
             h4(HTML(disclaimer_text)),
             
             HTML(intro_header),
             HTML(intro_text),
             HTML(need_text),
             HTML(ci_text),
             HTML(bleader_text),
             HTML(drb1_text),
             HTML(tce_text)
             
    ),
    
    ### tool page
    tabPanel('Predictor Tool',value=2,
      
      # Sidebar layout with a input and output definitions
      sidebarLayout(
        # Inputs: Select variables to plot
        sidebarPanel(width = 3,
          h3('Transplant Recipient Information', class='side-bar-header'),
          h5('This should be the same for Recipient-Donor Pairs.  These fields will lock if there are any added donors.  To unlock, press the "Clear All Donors" button below.'),
          h4("Recipient Label:"),
          textInput('pat_label',label=NULL, value = 'Recipient1',width = '80%'), 
          h4("Disease stage in AML/ALL/MDS:"),
          fluidRow(
            column(4,
                   radioButtons('disease', "Disease:",choices = c('AML', 'ALL', 'MDS'))
            ),
            column(4,
                   conditionalPanel('input.disease=="AML"',
                                    radioButtons('dis_stage1', "Stage:",choices = c('CR1', 'CR2/CR3', 'Advanced'))
                   ),
                   conditionalPanel('input.disease=="ALL"',
                                    radioButtons('dis_stage2', "Stage:",choices = c('CR1', 'CR2', 'CR3+'))
                   ),
                   conditionalPanel('input.disease=="MDS"',
                                    radioButtons('dis_stage3', "Stage:",choices = c('Early','Advanced'))
                   ),
            )
          ),
          h4("Recipient Co-Morbidity Index:"),
          radioGroupButtons(
            inputId = "hctcigp",
            label = NULL,
            choices = list("0" = 1, "1" = 2,
                           "2" = 3, "3+" = 4
            ),
            selected = 1
          ), 
          
          h4("Recipient Age:"),
          radioGroupButtons(
            inputId = "age",
            label = NULL,
            choices = list("0-18" = 1, "19-29" = 2, "30-39" = 3, "40-49" = 4, 
                           "50-59" = 5, "60+" = 6),
            selected = 1
          ), 
          
          h4("Recipient CMV Serostatus:"),
          radioButtons('rpt_cmv', label=NULL,choices = c('Positive', 'Negative', 'Missing')),
   
          
          h3('Transplant Recipient-Donor Pair Information', class='side-bar-header'),
          h4("Donor Label:"),
          textInput('did',label=NULL, width = '80%'), 
          h4("HLA-B Leader Match Status:"),
          radioGroupButtons(
            inputId = "match",
            label = NULL,
            choices = c('Leader-matched', 'Leader-mismatched'),
            selected = 'Leader-matched'
          ), 
          h4("HLA-DRB1/DQB1 Match Status:"),
          fluidRow(
            column(4,
                   radioButtons('dr_status', "HLA-DRB1:",choices = c('Match', 'Mismatch'))
            ),
            column(4,
                   radioButtons('dq_status', "HLA-DQB1:",choices = c('Match', 'Mismatch', 'Missing'))
            )
          ),
          # h4("HLA-DRB1 GVH Match Status:"),
          # radioGroupButtons(
          #   inputId = "dr_status",
          #   label = NULL,
          #   choices = c('Match', 'Mismatch'),
          #   selected = 'Match'
          # ),
  
          h4("HLA-DPB1 TCE Status:"),
          radioButtons('tce', label=NULL, choices = c('Matched or permissive', 'Non-permissive', 'Missing')),
  
          h4("Donor CMV Serostatus:"),
          radioButtons('dnr_cmv', label=NULL,choices = c('Positive', 'Negative', 'Missing')),
  
          actionButton('add_pair', "Add Donor Pair", class='add-button'),
          br(),
          actionButton('clear_all', 'Clear All Donor Pairs'),
          actionButton('clear_selected', 'Clear Selected Pairs'),
          
          ),
        
        #== Main panel for displaying outputs ----
        
        mainPanel(
          
          ### load script to put logo in header and custom css
           includeScript("www/addlogo.js"),
           includeCSS('www/custom.css'),
           HTML(version_text),
           h4(HTML(disclaimer_text)),
           plotlyOutput(outputId = "plots", height = '650px'),
           uiOutput('plotfootnote'),
           DT::dataTableOutput('table'),
           br(),
           HTML(intro_text)
        )
      )
    )
    )
  )
)
