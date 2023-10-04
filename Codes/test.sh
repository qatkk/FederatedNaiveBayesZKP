#!/bin/bash
# ######### Zokrates setup 
# cd ../zokrates 
# echo "Compiling zokrates code"
# time python3 ../zok_setup.py
# cd ../codes
#  ######## Encryption initialization 
# node initialize_encryption.js 
# echo "Initializing encryption"
# node sc_submit_public_key.js

echo "Please set your desired number of features if you want to change the data if not set the value in \"number_of_features.txt\" to a vlue less than 5"
python3.9 preprocessing.py 
echo "Preprocessing the data"
python3.9 data_categ.py
echo "Data categorized to labels"
python3.9 class_learn.py 
echo "Model trained!"
node encrypt_model.js
echo "Model encrypted and written to output/data.txt"
cd ../zokrates 
echo "Verify parameters"
time python3 ../zok_verify.py


# ######### Send model update to the smart contract 
cd ../codes
node sc_submit_model.js
echo "Model update submitted to the smart contract"
echo "The verification status for model update is:"
node sc_verification_status.js

# ###### Start decryption and send the partially decrypted values to the smart contract 
node sc_start_decryption.js


