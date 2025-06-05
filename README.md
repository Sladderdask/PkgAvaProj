# 📦 AdvancedBioinformaticPackage
**AdvancedBioinformaticPackage** 
provides tools and workflows for data preprocessing and analysis as 
part of the *Advanced Bioinformatics* course at Umeå University. 
The main purpose if this package is on identifying optimal spacer 
sequences for gene knockout using CRISPR-Cas9.

## 🚀 Installation and example usage

To get started:
1. Copy the URL from the repository.
2. Open a terminal and navigate to a directory of choice and run:
```bash
git clone URL
``` 

### 💻 Local installation
Install the packages using the following commands:
```bash
Rscript requirements.R
pip install -r requirements.txt
```
To install the development version of the package from GitHub:
```r
# If not already installed devtools, run:
install.packages("devtools") 

# Install the package
devtools::install_github("Sladderdask/AdvancedBioinformaticPackage")
```
#### 🧪 Example code
```r
#example usage
library(AvanceradbioinformatikPackage)

result <- fun(5)
print(result)
```

### 🐳 Docker
The program can be containerized using Docker to easily use the code 
despite different locally versions of programs. A Dockerfile can be 
found in the downloaded repository.

#### 🏗️ Build Docker image
To build the Docker image, run the following command in the project 
root directory:
```bash
docker build -t crispr_ko_screening .
```

#### ▶️ Run the container
To run the container, run the following command:
```bash
docker run -d --name crispr_ko_screening -p 8787:8787 -e PASSWORD=YOURPASSWORD crispr_ko_screening
```

#### 🔐 To log in to RStudio
**Username:** rstudio (default)

#### 🧭 To run the code
Change the working directory using:
```bash
setwd("/home/rstudio/projekt")
```

## 📁 Data files
Download the required files and save to a folder named **Data** in the PkgAvaProj project. Download the files at the following URLs:

sgRNA_data.xlsx

    https://orcs.thebiogrid.org/downloads/b5c747cfbc858b7564e95de50864ad95/b5c747cfbc858b7564e95de50864ad95.zip
Library_A.csv

    https://media.addgene.org/cms/filer_public/a4/b8/a4b8d181-c489-4dd7-823a-fe267fd7b277/human_geckov2_library_a_09mar2015.csv
Library_B.csv

    https://media.addgene.org/cms/filer_public/2d/8b/2d8baa42-f5c8-4b63-9c6c-bd98f333b29e/human_geckov2_library_b_09mar2015.csv
RNA_seq_data.gz

    https://ftp.ncbi.nlm.nih.gov/geo/series/GSE169nnn/GSE169614/suppl/GSE169614%5F52677%5Fstar.Homo%5Fsapiens.GRCh38.78.htseq.counts.tab.gz

## ⚙️ Usage
To **visualize** the results run the following command in the root directory:
```bash
Rscript shiny/app.R
```
**Open** the given wedadress

To **run** the code from scratch, follow the steps:
1. **Download** the required files (see 📁 **Data files** above)
2. To **Create** the SQLite database:
```bash
python source_code/DatabasLite.py
```
3. To **format** the data and **add** to the database:
```bash
Rscript source_code/Data_formatting.R
```
4. Run the **Machiner learning** code either in python or R:
```bash
Rscript source_code/Machine_learning.R
Python source_code/Machine_learning.py
```
5. To **plot** the results:
```bash
python source_code/Shapping.py
```
**Save** the plots to the www folde in shiny/www path

6. To **visualize** the results run the following command in the root directory:
```bash
Rscript shiny/app.R
```
**Open** the given wedadress


## 🏠 pkgdown site
For visualization of the AdvancedBioinformaticPackage run the following command in the root drectory:
```bash
pkgdown::build_site()
```

## 📝 License
This package is licensed under the MIT License. 
See the LICENSE file for details.

## 👥 Authors
Dennis Harding – dennis.harding2@gmail.com

Moa Ögren – moaa.ogren@gmail.com

## 🎓 Course
This package was developed for the **Advanced Bioinformatics** course at Umeå University.

## 🤝 Contributing
We **DO** welcome contributions.
