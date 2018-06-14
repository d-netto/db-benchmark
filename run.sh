#!/bin/bash
set -e

# get config
source run.conf

## ensure all presto shutdown
#./presto/shutdown-presto.sh || true

# produce iteration dictionaries from data.csv
./init-setup-iteration.R

# set batch
export BATCH=$(date +%s)

echo "# Benchmark run $BATCH started"

## test network speed
#./servertest.sh
#Rscript -e 'data.table::fread("servertest.log")[substr(V3,1,2)!="Gb" | V2 < 9, if (!.N) q("no") else if(any(V2<5)) stop("slow (< 5 Gb) network interface on nodes: ",paste(V1[V2<5],collapse=", "), call.=FALSE) else warning("network interface below 9 Gb on nodes: ",paste(V1,collapse=", "), call.=FALSE)]'
## spark
#./spark/spark.sh

## test network speed
#./servertest.sh
#Rscript -e 'data.table::fread("servertest.log")[substr(V3,1,2)!="Gb" | V2 < 9, if (!.N) q("no") else if(any(V2<5)) stop("slow (< 5 Gb) network interface on nodes: ",paste(V1[V2<5],collapse=", "), call.=FALSE) else warning("network interface below 9 Gb on nodes: ",paste(V1,collapse=", "), call.=FALSE)]'
## impala
#./impala/impala.sh

# datatable
./datatable/datatable.sh

## test network speed
#./servertest.sh
#Rscript -e 'data.table::fread("servertest.log")[substr(V3,1,2)!="Gb" | V2 < 9, if (!.N) q("no") else if(any(V2<5)) stop("slow (< 5 Gb) network interface on nodes: ",paste(V1[V2<5],collapse=", "), call.=FALSE) else warning("network interface below 9 Gb on nodes: ",paste(V1,collapse=", "), call.=FALSE)]'
## h2o
#./h2o/h2o.sh

# dplyr
./dplyr/dplyr.sh

# pandas
./pandas/pandas.sh

## test network speed
#./servertest.sh
#Rscript -e 'data.table::fread("servertest.log")[substr(V3,1,2)!="Gb" | V2 < 9, if (!.N) q("no") else if(any(V2<5)) stop("slow (< 5 Gb) network interface on nodes: ",paste(V1[V2<5],collapse=", "), call.=FALSE) else warning("network interface below 9 Gb on nodes: ",paste(V1,collapse=", "), call.=FALSE)]'
## dask
#./dask/dask.sh

## test network speed
#./servertest.sh
#Rscript -e 'data.table::fread("servertest.log")[substr(V3,1,2)!="Gb" | V2 < 9, if (!.N) q("no") else if(any(V2<5)) stop("slow (< 5 Gb) network interface on nodes: ",paste(V1[V2<5],collapse=", "), call.=FALSE) else warning("network interface below 9 Gb on nodes: ",paste(V1,collapse=", "), call.=FALSE)]'
## presto
#./presto/presto.sh

# pydatatable
./pydatatable/pydatatable.sh

# publish timing locally
#Rscript -e 'rmarkdown::render("index.Rmd")'

# groupby benchplot
Rscript -e 'source("benchplot.R"); nr<-fread("data.csv")[task=="groupby" & active==TRUE, unique(rows)]; sapply(nr, benchplot)'

# publish benchmark, only if token file exists
[ -f ./token ] && ./publish.sh

# completed
echo "# Benchmark run $BATCH has been completed in $(($(date +%s)-$BATCH))s"

## test network speed
#./servertest.sh
#Rscript -e 'data.table::fread("servertest.log")[substr(V3,1,2)!="Gb" | V2 < 9.5, if (!.N) q("no") else warning("slow (< 9.5 Gb) network interface on nodes: ",paste(V1,collapse=","), call.=FALSE)]'
