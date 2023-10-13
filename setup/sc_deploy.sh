#!/bin/bash
cd .. 
npx hardhat compile

npx hardhat run ./codes/deploy.js --network goerli

