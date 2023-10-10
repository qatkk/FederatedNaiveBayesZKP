#!/bin/bash


result=$(fgrep "Proof memory proof, " ../smart_contracts/MVSC.sol)
result=$(echo "${result// Proof memory proof,}")
sed "62s/.*memory input;.*/$result;/" ../smart_contracts/FLSC.sol > ../smart_contracts/temp_sc.sol

result=$(fgrep "Proof memory proof, " ../smart_contracts/DVSC.sol)
result=$(echo "${result// Proof memory proof,}")
sed "122s/.*memory input;.*/$result;/" ../smart_contracts/temp_sc.sol > ../smart_contracts/FLSC.sol

rm ../smart_contracts/temp_sc.sol
