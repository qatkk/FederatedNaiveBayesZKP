#!/bin/bash



###### Start decryption and send the partially decrypted values to the smart contract 
node ../codes/sc_start_decryption.js
echo "Started the decryption phase"
echo "This will update the partially decrypted global model parameters to the partially decrypted one"
number_of_MOs=$(node -pe 'JSON.parse(process.argv[1]).number_of_MOs' $(< ../configs/params.json))
start=0
for ((i=$start; i<$number_of_MOs; i++))
    do
            node ../codes/partial_decrypt.js $i
            echo "Retrieving the global model parameters from the FLSC to do the partial decryption"

            cd ../zokrates/decryption 
            python3 ../../setup/decryption_verify.py 

            cd ../../codes
            node sc_submit_decryption.js 
    done

echo "Decryption finished!"
echo "Running the decryption to get the decrypted model parameters; as a test this is only done for the mean parameters!"
node ../codes/decrypt.js


