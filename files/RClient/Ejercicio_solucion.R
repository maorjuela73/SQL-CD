library(DBI)
library(RPostgres)
library(ggplot2)

pw<- {
  "postgres"
}

con <- dbConnect(RPostgres::Postgres()
                 , host='localhost'
                 , port='5432'
                 , dbname='dvdrental'
                 , user='postgres'
                 , password=pw)

rm(pw) # removes the password

dbListTables(con)
dbListFields(con, "payment")
dbReadTable(con, "payment")

# Recaudo por estado del cliente
res <- dbSendQuery(con, "select active, sum(amount) from payment pay join customer cus on pay.customer_id = cus.customer_id group by active;")
data <- dbFetch(res)
plot <- ggplot(data) + geom_col(aes(x = active, y = sum))
dbClearResult(res)

# Top 10 recaudo por país
res <- dbSendQuery(con, "select country, sum(amount) from payment pay join customer cus on pay.customer_id = cus.customer_id 
join address adr on cus.address_id=adr.address_id join city cty on adr.city_id=cty.city_id join country ctr on cty.country_id = ctr.country_id
group by country
order by sum(amount) desc
limit 10;")
data <- dbFetch(res)
plot <- ggplot(data) + geom_col(aes(x = country, y = sum))
dbClearResult(res)


# Disconnect from the database
dbDisconnect(con)