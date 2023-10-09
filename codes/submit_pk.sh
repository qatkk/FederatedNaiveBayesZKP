#!/bin/bash


 ######## Encryption initialization 
node initialize_encryption.js 
echo "Initializing encryption"
node sc_submit_public_key.js
