# Install and load the necessary packages:
install.packages(c("shiny", "shinydashboard", "DT", "RSQLite"))
library(shiny)
library(shinydashboard)
library(DT)
library(RSQLite)

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
  
  # create a connection to the database
  conn <- dbConnect(RSQLite::SQLite(), "issues.db")
  
  # create the issues table if it doesn't exist
  dbSendQuery(conn, "
    CREATE TABLE IF NOT EXISTS issues (
      IssueID INTEGER PRIMARY KEY,
      Title TEXT,
      Description TEXT,
      Status TEXT
    )
  ")
  
  # create a reactive dataframe to store issues
  issues <- reactiveVal(data.frame(
    IssueID = integer(),
    Title = character(),
    Description = character(),
    Status = character(),
    stringsAsFactors = FALSE
  ))
  
  # load issues from the database when the app starts
  onStartup(function() {
    query <- dbSendQuery(conn, "SELECT * FROM issues")
    issues(dbFetch(query))
    dbClearResult(query)
  })
  
  # observe when a new issue is submitted and add it to the database and dataframe
  observeEvent(input$submit, {
    new_issue <- data.frame(
      IssueID = nrow(issues()) + 1,
      Title = input$title,
      Description = input$description,
      Status = "Open"
    )
    issues(rbind(issues(), new_issue))
    dbSendQuery(conn, paste0("
      INSERT INTO issues (IssueID, Title, Description, Status)
      VALUES (", new_issue$IssueID, ", '", new_issue$Title, "', '",
        new_issue$Description, "', '", new_issue$Status, "')"
    ))
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
  
  # observe when an issue is edited and update the database and dataframe
  observeEvent(input$edit_issue, {
    id <- input$edit_issue$id
    column <- input$edit_issue$column
    value <- input$edit_issue$value
    issues()[issues()$IssueID == id, column] <- value
    dbSendQuery(conn, paste0("
      UPDATE issues
      SET ", colnames(issues())[column], " = '", value, "'
      WHERE IssueID = ", id
    ))
  })
  
  # close the database connection when the app is stopped
  onStop(function() {
    dbDisconnect(conn)
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)
