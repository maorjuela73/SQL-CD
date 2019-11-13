library(DBI)
library(RPostgres)

pw<- {
  "postgres"
}

con <- dbConnect(RPostgres::Postgres()
                 , host='rdataserver.cxifh5b1hjjf.us-west-2.rds.amazonaws.com'
                 , port='5432'
                 , dbname='postgres'
                 , user='postgres'
                 , password=pw)

rm(pw) # removes the password

dbListTables(con)
dbWriteTable(con, "mtcars", mtcars)
dbListTables(con)

dbListFields(con, "mtcars")
dbReadTable(con, "mtcars")

# You can fetch all results:
res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
dbFetch(res)
dbClearResult(res)

# Or a chunk at a time
res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
while(!dbHasCompleted(res)){
  chunk <- dbFetch(res, n = 5)
  print(nrow(chunk))
}
# Clear the result
dbClearResult(res)

# Disconnect from the database
dbDisconnect(con)