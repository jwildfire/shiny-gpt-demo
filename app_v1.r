# Description from ChatGPT: This app includes two tabs: "Create Issue" and "View Issues". In the "Create Issue" tab, users can enter a title and description for a new issue, and submit it to the system. In the "View Issues" tab, all issues in the system are displayed in a table.

# You can customize this app further by adding additional form inputs for issue details (e.g., priority, assignee, due date), adding more tabs for different views of the data, and adding additional functionality for updating and deleting issues.

install.packages(c("shiny", "shinydashboard", "DT"))
library(shiny)
library(shinydashboard)
library(DT)

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
              ),
      tabItem(tabName = "view",
              h2("View Issues"),
              # display issues in a table
              )
    )
  )
)

server <- function(input, output) {
  
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
    updateTextInput(session, "description", value = "")
  })
  
  # display the issues in a table
  output$issue_table <- renderDT({
    datatable(issues(), options = list(pageLength = 10))
  })
}

shinyApp(ui, server)
