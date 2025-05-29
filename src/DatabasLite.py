import sqlite3
import os


definition = """

CREATE TABLE IF NOT EXISTS sgRNA_data(
  sgRNAid VARCHAR PRIMARY KEY,
  LFC REAL,
  score REAL,
  LFC_binary INTEGER
);

CREATE TABLE GeCKO(
  UID VARCHAR PRIMARY KEY,
  Sequence TEXT,
  nt1 TEXT, 
  nt2 TEXT, 
  nt3 TEXT, 
  nt4 TEXT, 
  nt5 TEXT, 
  nt6 TEXT, 
  nt7 TEXT, 
  nt8 TEXT, 
  nt9 TEXT, 
  nt10 TEXT, 
  nt11 TEXT, 
  nt12 TEXT, 
  nt13 TEXT, 
  nt14 TEXT, 
  nt15 TEXT, 
  nt16 TEXT, 
  nt17 TEXT, 
  nt18 TEXT, 
  nt19 TEXT, 
  nt20 TEXT,
  FOREIGN KEY (UID) REFERENCES sgRNA_DATA (sgRNAid)
  
);

CREATE TABLE RNA_seq(
  ensemble_id TEXT,
  gene_name TEXT,
  fpkm_counted REAL,
  fpkm_binary INTEGER
);

"""

try:
    os.remove("src/DatabasLite.db")
except FileNotFoundError:
    pass
except OSError as e:
  print(f"An error occured: {e}")

connection = sqlite3.connect("src/DatabasLite.db")

def define_db():
    cursor = connection.cursor()
    for command in definition.split(";"):
        cursor.execute(command)

define_db()

connection.close()

