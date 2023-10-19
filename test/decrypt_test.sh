#!/bin/bash



###### Start decryption and send the partially decrypted values to the smart contract 
node ../codes/sc_start_decryption.js
echo "Started the decryption phase"
echo "This will update the partially decrypted global model parameters to the partially decrypted one"

echo "Do you want to do the complete decryption?, Answer with(Y/N)"
read is_complete_decryption
if [ $is_complete_decryption == 'N' ] || [ $is_complete_decryption == 'n' ]
then
    echo "Your answer is $is_complete_decryption , this will do the partial decryption only once!"
    node ../codes/partial_decrypt.js 
    echo "Retrieving the global model parameters from the FLSC to do the partial decryption"

    cd ../zokrates/decryption 
    python3 ../../decryption_verify.py 

    cd ../../codes
    node sc_submit_decryption.js 
elif [ $is_complete_decryption == 'Y' ] || [ $is_complete_decryption == 'y' ]
    then
    echo "Your answer is $is_complete_decryption , this will do the partial decryption for the number of MOs!"
    for i in 1 2 3
        do
                node ../codes/partial_decrypt.js 
                echo "Retrieving the global model parameters from the FLSC to do the partial decryption"

                cd ../zokrates/decryption 
                python3 ../../decryption_verify.py 

                cd ../../codes
                node sc_submit_decryption.js 
        done
else 
    echo "Wrong answer, run this script again!"
fi


