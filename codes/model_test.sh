#!/bin/bash

python3.9 preprocessing.py 
echo "Preprocessing the data"
python3.9 data_categ.py
echo "Data categorized to labels"
python3.9 class_learn.py 
echo "Model trained!"
node encrypt_model.js
echo "Model encrypted and written to output/data.txt"
cd ../zokrates/model_verif
echo "Verify parameters"
time python3 ../../zok_verify.py


# ######### Send model update to the smart contract 
cd ../../codes
node sc_submit_model.js
echo "Model update submitted to the smart contract"