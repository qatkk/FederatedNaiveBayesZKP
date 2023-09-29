#!/bin/bash
cd ../zokrates 
echo "Compiling zokrates code"
time python3 ../zok_setup.py
cd ../codes
echo "Please set your desired number of features if you want to change the data if not set the value in \"number_of_features.txt\" to a vlue less than 5"
python3.9 preprocessing.py 
echo "Preprocessing the data"
python3.9 data_categ.py
echo "Data categorized to labels"
python3.9 class_learn.py 
echo "Model trained!"
node initialize_encryption.js 
echo "Initializing encryption"
node encrypt_model.js
echo "Model encrypted and written to output/data.txt"
cd ../zokrates 
echo "Verify parameters"
time python3 ../zok_verify.py

#  Todo : add the submit_model to automatically submit a model update to the contract
#          add the parts corresponding to the decryption
# node submit_model.js
