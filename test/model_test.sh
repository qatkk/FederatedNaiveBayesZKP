#!/bin/bash
echo "How many model updates do you want to have? answer between 1-5"
read model_submissions
start=0
rm -f ../output/model_params.json  
for ((i=$start; i<$model_submissions; i++))
do
    python3 ../codes/preprocessing.py 
    echo "Preprocessing the data"
    python3 ../codes/data_categ.py
    echo "Data categorized to labels"
    python3 ../codes/class_learn.py 
    echo "Model trained!"
    node ../codes/encrypt_model.js
    echo "Model encrypted and written to output/data.txt"
    cd ../zokrates/model_verif
    echo "Verify parameters"
    time python3 ../../setup/zok_verify.py


    # ######### Send model update to the smart contract 
    cd ../../codes
    node sc_submit_model.js
    echo "Model update submitted to the smart contract"
done
