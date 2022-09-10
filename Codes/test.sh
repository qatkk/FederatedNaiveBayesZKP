#!/bin/bash
cd ../zokrates 
echo "Compiling zokrates code"
python3 ../zok_setup.py
cd ../Codes
echo "Please set your desired number of features if you want to change the data if not set the value in \"number_of_features.txt\" to a vlue less than 5"
python3 preprocessing.py 
echo "Preprocessing the data"
python3 data_categ.py
echo "Data categorized to labels"
python3 class_learn.py 
echo "Model trained!"
node initialize_encryption.js 
echo "Initializing encryption"
node encrypt_model.js
echo "Model encrypted and written to data.txt"
cd ../zokrates 
echo "Verify parameters"
python3 ../zok_verify.py