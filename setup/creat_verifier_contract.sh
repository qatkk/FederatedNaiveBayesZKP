#!/bin/bash


sed "s/contract Verifier.*/contract MVSC{/"  ../contracts/MVSC.sol > ../contracts/verifier.sol
sed '1,145d' ../contracts/DVSC.sol > ../contracts/temp_sc.sol
sed "s/contract Verifier.*/contract DVSC{/"  ../contracts/temp_sc.sol >> ../contracts/verifier.sol
rm ../contracts/temp_sc.sol