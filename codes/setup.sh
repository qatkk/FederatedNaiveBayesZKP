#!/bin/bash
######### Zokrates model verif setup 
cd ../zokrates/model_verif 
echo "Compiling model verification zokrates codes"
time python3 ../../zok_setup.py

######### Zokrates decryption verification
cd ../decryption 
echo "Compiling decryption verification zokrates code"
time python3 ../../decryption_setup.py
cd ../../codes

echo "Changing verification input sizes for the FLSC smart contract"
./text_replace.sh

echo "Creating the verifier.sol file for deployment" 
./creat_verifier.sh



