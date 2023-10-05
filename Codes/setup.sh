#!/bin/bash
######### Zokrates model verif setup 
cd ../zokrates/model_verif 
echo "Compiling model verification zokrates codes"
time python3 ../../zok_setup.py
cd ../../codes

######### Zokrates decryption verification
cd ../zokrates/decryption 
echo "Compiling decryption verification zokrates code"
time python3 ../../decryption_setup.py
cd ../../codes




