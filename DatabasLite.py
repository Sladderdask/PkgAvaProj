import sqlite3
import os


definition = """

CREATE TABLE IF NOT EXISTS sgRNA_data(
  sgRNAid VARCHAR PRIMARY KEY,
  LFC REAL,
  score REAL
);

CREATE TABLE GeCKO(
  UID VARCHAR PRIMARY KEY,
  Sequence TEXT,
  FOREIGN KEY (UID) REFERENCES sgRNA_DATA (sgRNAid)
);

"""

try:
    os.remove("DatabasLite.db")
except FileNotFoundError:
    pass
except OSError as e:
  print(f"An error occured: {e}")

connection = sqlite3.connect("DatabasLite.db")

def define_db():
    cursor = connection.cursor()
    for command in definition.split(";"):
        cursor.execute(command)

define_db()
