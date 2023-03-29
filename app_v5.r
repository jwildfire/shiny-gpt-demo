library(shiny)
library(DT)
library(RSQLite)

# Define the UI
ui <- fluidPage(
  
  # input form
  textInput("title", "Title"),
  textAreaInput("description", "Description"),
  actionButton("submit", "Submit"),
  
  # issue table
  dataTableOutput("issue_table")
  
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
  
  # update the issue status in the database when it is edited in the app
  observeEvent(input$issue_table_cell_edit, {
    info = input$issue_table_cell_edit
    col = info$col + 1
    row = info$row
    id = issues()[row, "IssueID"]
    new_val = info$value
    dbSendQuery(conn, paste0("
      UPDATE issues
      SET ", colnames(issues())[col], " = '",
        new_val, "'
      WHERE IssueID = ", id
    ))
    # update the issues dataframe
    issues()[row, col] <- new_val
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
      editable = TRUE
    )
  })
  
  # close the database connection when the app stops
  onStop(function() {
    dbDisconnect(conn)
  })
  
}

# define the startup function to load issues from the database when the app starts
startup <- function() {
  # create a connection to the database
  conn <- dbConnect(RSQLite::SQLite(), "issues.db")
  
  # load issues from the database into a data frame
  issues_df <- dbGetQuery(conn, "SELECT * FROM issues")
  
  # create a reactive dataframe to store issues
  issues <- reactiveVal(issues_df)
  
  # close the database connection
  dbDisconnect(conn)
  
  # return the reactive dataframe
  issues
}

# Run the application
shinyApp(ui = ui, server=server, onStart=startup)
