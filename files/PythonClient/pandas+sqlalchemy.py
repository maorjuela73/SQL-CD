import pandas as pd
from sqlalchemy import create_engine, text

engine = create_engine("postgresql+psycopg2://postgres:postgres@localhost/dvd_rentals")

def runQuery(sql):
    result = engine.connect().execute((text(sql)))
    return pd.DataFrame(result.fetchall(),columns = result.keys())

query1 = "SELECT * FROM payment;"
runQuery(query1).head()