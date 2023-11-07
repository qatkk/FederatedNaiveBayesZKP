#!/bin/bash

####### Set scheme parameters for zokrates files 
echo "Setting scheme parameters for zokrates files from configs folder"
./zokrates_parameter_setup.sh

######### Zokrates model verif setup 
cd ../zokrates/model_verif 
echo "Compiling model verification zokrates codes"
time python3 ../../setup/zok_setup.py

######### Zokrates decryption verification
cd ../decryption 
echo "Compiling decryption verification zokrates code"
time python3 ../../setup/decryption_setup.py

cd ../../setup
echo "Changing verification input sizes for the FLSC smart contract"
./set_FLSC_contract.sh

echo "Creating the verifier.sol file for deployment" 
./creat_verifier_contract.sh


echo "Deploying the FLSC contract" 
./sc_deploy.sh

echo " The FLSC contract is now deployed, you can interact with the contract and run the test scripts to see Federify's functionality"

rm -rf ../output/
mkdir ../output

