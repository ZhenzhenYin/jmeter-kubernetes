#!/usr/bin/env bash
# Script created to launch Jmeter tests with csv data files directly from the current terminal without accessing the jmeter master pod.
# It requires that you supply the path to the directory with jmx file and csv files
# Directory structure of jmx with csv supposed to be:
# _test_name_/
# _test_name_/_test_name_.jmx
# _test_name_/test_data1.csv
# _test_name_/test_data2.csv
# i.e. jmx file name have to be the same as directory name.
# After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir=$(pwd)

# Get namesapce variable
tenant=$(awk '{print $NF}' "$working_dir"/tenant_export)

jmx_dir=$1

if [ ! -d "$jmx_dir" ];
then
    echo "Test script dir was not found"
    echo "Kindly check and input the correct file path"
    exit
fi

# Get Master pod details

printf "Copy %s to master\n" "${jmx_dir}.jmx"

master_pod=$(kubectl get po -n "$tenant" | grep jmeter-master | awk '{print $1}')

kubectl cp "${jmx_dir}/${jmx_dir}.jmx" -n "$tenant" "$master_pod":/

# Get slaves

printf "Get number of slaves\n"

slave_pods=($(kubectl get po -n "$tenant" | grep jmeter-slave | awk '{print $1}'))

# for array iteration
slavesnum=${#slave_pods[@]}

# for split command suffix and seq generator
slavedigits="${#slavesnum}"

printf "Number of slaves is %s\n" "${slavesnum}"

shuf() { awk 'BEGIN {srand(); OFMT="%.17f"} {print rand(), $0}' "$@" |
	               sort -k1,1n | cut -d ' ' -f2-; }
# Split and upload csv files

for csvfilefull in "${jmx_dir}"/*.csv

  do

  csvfile="${csvfilefull##*/}"

  printf "Processing %s file..\n" "$csvfile"

  for j in $(seq -f "%0${slavedigits}g" 0 $((slavesnum-1)))
  do
    printf "Copy %s to %s on %s\n" "${csvfile}" "${csvfile}" "${slave_pods[$((10#$j))]}"
    cat "${jmx_dir}/${csvfile}" | shuf > "${jmx_dir}/${csvfile}".shuffled
    kubectl -n "$tenant" cp "${jmx_dir}/${csvfile}.shuffled" "${slave_pods[$((10#$j))]}":/"${csvfile}"
    
  done # for j in "${slave_pods[@]}"

done # for csvfile in "${jmx_dir}/*.csv"

## Echo Starting Jmeter load test

kubectl exec -ti -n "$tenant" "$master_pod" -- /bin/bash /load_test "/${jmx_dir}.jmx" $2

kubectl cp "$tenant"/"$master_pod":"$2"/ "$2"/
