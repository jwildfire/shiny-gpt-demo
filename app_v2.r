# Install and load the necessary packages:
install.packages(c("shiny", "shinydashboard", "DT"))
library(shiny)
library(shinydashboard)
library(DT)

# Define the UI
ui <- dashboardPage(
  dashboardHeader(title = "Issue Management System"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Create Issue", tabName = "create", icon = icon("plus")),
      menuItem("View Issues", tabName = "view", icon = icon("list"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "create",
              h2("Create Issue"),
              # add form inputs for issue details
              textInput("title", "Title"),
              textAreaInput("description", "Description"),
              actionButton("submit", "Submit")
              ),
      tabItem(tabName = "view",
              h2("View Issues"),
              # display issues in a table
              DT::dataTableOutput("issue_table")
              )
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  
  # create a reactive dataframe to store issues
  issues <- reactiveVal(data.frame(
    IssueID = integer(),
    Title = character(),
    Description = character(),
    Status = character(),
    stringsAsFactors = FALSE
  ))
  
  # observe when a new issue is submitted and add it to the dataframe
  observeEvent(input$submit, {
    new_issue <- data.frame(
      IssueID = nrow(issues()) + 1,
      Title = input$title,
      Description = input$description,
      Status = "Open"
    )
    issues(rbind(issues(), new_issue))
    # clear form inputs
    updateTextInput(session, "title", value = "")
    updateTextAreaInput(session, "description", value = "")
  })
  
  # display the issues in a table
  output$issue_table <- DT::renderDataTable({
    DT::datatable(
      issues(),
      options = list(pageLength = 10, 
                     rowCallback = JS(
                       "function(row, data, index) {",
                       "  $(row).addClass(data[3]);",
                       "}"
                     )),
      editable = TRUE,
      callback = JS(
        "table.on('edit.dt', function(e, cell, splice, newVal) {",
        "  var row = cell.index().row;",
        "  var column = cell.index().column;",
        "  var id = table.cell(row, 0).data();",
        "  Shiny.setInputValue('edit_issue', {'id': id, 'column': column, 'value': newVal});",
        "});"
      )
    )
  })
  
  # observe when an issue is edited and update the dataframe
  observeEvent(input$edit_issue, {
    id <- input$edit_issue$id
    column <- input$edit_issue$column
    value <- input$edit_issue$value
    issues()[issues()$IssueID == id, column] <- value
  })
}

# Run the application
shinyApp(ui = ui, server = server)
