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

### License
This package is licensed under the MIT License. 

See the LICENSE file for details.



### Authors
Dennis Harding – dennis.harding2@gmail.com

Moa Ögren – moaa.ogren@gmail.com

### Course
This package was developed for the Advanced Bioinformatics course at 
Umeå University.

### Data files
If one wants to check the data used in the project, one can dowload the files at the following URLs:

    https://orcs.thebiogrid.org/downloads/b5c747cfbc858b7564e95de50864ad95/b5c747cfbc858b7564e95de50864ad95.zip
    https://media.addgene.org/cms/filer_public/a4/b8/a4b8d181-c489-4dd7-823a-fe267fd7b277/human_geckov2_library_a_09mar2015.csv
    https://media.addgene.org/cms/filer_public/2d/8b/2d8baa42-f5c8-4b63-9c6c-bd98f333b29e/human_geckov2_library_b_09mar2015.csv


### Contributing

We DO welcome contributions.
