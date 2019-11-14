import psycopg2

con = psycopg2.connect(user = "postgres",
                        password = "postgres",
                        host = "localhost",
                        port = "5432",
                        database = "dvd_rentals")

cur = con.cursor()

cur.execute("CREATE TABLE test (id serial PRIMARY KEY, num integer, data varchar);")

cur.execute("INSERT INTO test (num, data) VALUES (%s, %s)", (100, "abc'def"))

cur.execute("SELECT * FROM payment;")
cur.fetchone()

cur.execute("SELECT * FROM payment;")
pd.DataFrame(cur.fetchall())

con.commit()

cur.close()
con.close()