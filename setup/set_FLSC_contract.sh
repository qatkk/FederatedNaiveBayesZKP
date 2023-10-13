#!/bin/bash


result=$(fgrep "Proof memory proof, " ../contracts/MVSC.sol)
result=$(echo "${result// Proof memory proof,}")
sed "62s/.*memory input;.*/$result;/" ../contracts/FLSC.sol > ../contracts/temp_sc.sol

result=$(fgrep "Proof memory proof, " ../contracts/DVSC.sol)
result=$(echo "${result// Proof memory proof,}")
sed "122s/.*memory input;.*/$result;/" ../contracts/temp_sc.sol > ../contracts/FLSC.sol

rm ../contracts/temp_sc.sol
