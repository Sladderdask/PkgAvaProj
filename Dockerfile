# Build RStudio-based image
FROM rocker/tidyverse:4.2.2

#RUN apt-get update --allow-releaseinfo-change && apt-get install -y python3 python3-pip
RUN apt-get update && apt-get install -y python3 python3-pip

# Set working directory
WORKDIR /home/rstudio/projekt

# Copy R and Python dependency files into the container
COPY requirements.txt ./
COPY requirements.R ./
COPY ./source_code ./source_code
COPY ./shiny ./shiny

# Install Python packages
RUN pip3 install -r requirements.txt

# Force reticulate to use the correct Python path where the python packages are installed
ENV RETICULATE_PYTHON=/usr/bin/python3

# Install R packages
RUN Rscript requirements.R


