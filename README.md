# 📦 AvanceradBioinformatikPackage

**AvanceradBioinformatikPackage** 
provides tools and workflows for data preprocessing and analysis as 
part of the *Advanced Bioinformatics* course at Umeå University. 
The main purpose if this package is on identifying optimal spacer 
sequences for gene knockout using CRISPR-Cas9.

### 🚀 Installation and example usage

To install the development version of the package from GitHub:

```r
# If not already installed devtools, run:
install.packages("devtools") 

# Install the package
devtools::install_github("Sladderdask/AvanceradBioinformatikPackage")
```

### Local installation
Install the packages using
```r
Rscript requirements.R
pip install -r requirements.txt
```


```r
#example usage
library(AvanceradbioinformatikPackage)

result <- fun(5)
print(result)
```

### Docker
The program can be containerized using Docker to easily use the code 
despite different locally versions of programs. A Dockerfile can be 
found in the downloaded repository.

#### Build Docker image
To build the Docker image, run the following command in the project 
root directory

```bash
docker build -t CRISPR_KO_screening .
```

#### Run the container
To run the container, run the following commands
```bash
docker run -d 
-- name CRISPR_KO_screening
-p 8787:8787
-e PASSWORD=YOURPASSWORD
CRISPR_KO_screening
```

#### To log in to RStudio
username -> Default set to rstudio

#### To run the code
Change the workiing directory using:
```bash
Import os
os.chdir("/home/rstudio/projekt/src")
```

### Usage
To run the code, follow the steps
1. Download the given files, see instructions below in Data files.
2. Create the SQLite database
```bash
python src/DatabasLite.py
```
3. Format the data and add to the database
```bash
Rscript src/Data_formatting.R
```
4. Run the Machiner learning code
```bash
Rscript src/Machine_learning.R
```
5. Visualize the results???
INSERT INFOR



### Data files
Download the used files and save to a data folder in the PkgAvaProj project. Download the files at the following URLs:

sgRNA_data.xlsx

    https://orcs.thebiogrid.org/downloads/b5c747cfbc858b7564e95de50864ad95/b5c747cfbc858b7564e95de50864ad95.zip
Library_A.csv

    https://media.addgene.org/cms/filer_public/a4/b8/a4b8d181-c489-4dd7-823a-fe267fd7b277/human_geckov2_library_a_09mar2015.csv
Library_B.csv

    https://media.addgene.org/cms/filer_public/2d/8b/2d8baa42-f5c8-4b63-9c6c-bd98f333b29e/human_geckov2_library_b_09mar2015.csv
RNA_seq_data.gz

    https://ftp.ncbi.nlm.nih.gov/geo/series/GSE169nnn/GSE169614/suppl/GSE169614%5F52677%5Fstar.Homo%5Fsapiens.GRCh38.78.htseq.counts.tab.gz


### License
This package is licensed under the MIT License. 
See the LICENSE file for details.


### Authors
Dennis Harding – dennis.harding2@gmail.com
Moa Ögren – moaa.ogren@gmail.com

### Course
This package was developed for the Advanced Bioinformatics course at 
Umeå University.


### Contributing
We DO welcome contributions.
