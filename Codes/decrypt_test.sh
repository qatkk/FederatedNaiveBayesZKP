#!/bin/bash



# ###### Start decryption and send the partially decrypted values to the smart contract 
node sc_start_decryption.js
echo "Started the decryption phase"
echo "This will update the partially decrypted global model parameters to the partially decrypted one"

node partial_decrypt.js 
echo "Retrieving the global model parameters from the FLSC to do the partial decryption"

cd ../zokrates/decryption 
python3 ../../decryption_verify.py 

cd ../../codes
node sc_submit_decryption.js 

