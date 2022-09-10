const {BabyJubPoint, G, Fr, Frr, randFr, subOrder, order} = require("./BabyJubPoint");
const utils = require("ffjavascript").utils;
const fs = require("fs");
const web3 = require("web3-utils"); 
const math = require("math");
const ethers = require('ethers');
const {exec}  = require('child_process');
const provider = new ethers.providers.InfuraProvider("goerli", "64f2b92ea98d47b8a584976f7f051d08");
const contractAddr =  fs.readFileSync('./ContractAddr.txt','utf8');
const { promisify } = require('util');
const sleep = promisify(setTimeout);
const contractABI = fs.readFileSync('./ABI.txt','utf8');
let privateKey = "5f22a80a0824462fc1ed3b79306696b79dd3ed5dbb9a69287f1aa2cddb4413ef";
let wallet = new ethers.Wallet(privateKey, provider);
const contract = new ethers.Contract(contractAddr, contractABI, wallet);
let number_of_attributes = parseInt(fs.readFileSync('./number_of_features.txt','utf8'));


public_key =  fs.readFileSync('./pubkey_compact.txt','utf8');
// public_key = public_key.split(" ");
console.log(public_key);
async function just_test() {
try {
    await contract.submit_pubkey(BigInt(public_key.toString()), {gasLimit: 5000000}).then ((tx)=>{
        console.log(tx);
        sleep(20000);
    });
}catch (err){
    console.log(err);
}

}

just_test().then(async ()=>{
    input = fs.readFileSync('./sc_input.txt','utf8');
    input = input.split(' ');
    console.log(input.length);
    sleep(20000);
    temp = input.splice(1,number_of_attributes * 2); 
    const means_R = [];
    while(temp.length) means_R.push(temp.splice(0,2));
        
    temp = input.splice(1,number_of_attributes * 2 ); 
    const means_C= [];
    while(temp.length) means_C.push(temp.splice(0,2));
    temp = input.splice(1,number_of_attributes * 2 ); 
    const vars_R= [];
    while(temp.length) vars_R.push(temp.splice(0,2));
    temp = input.splice(1,number_of_attributes * 2 ); 
    const vars_C= [];
    while(temp.length) vars_C.push(temp.splice(0,2));
    

    proof = JSON.parse(fs.readFileSync('../zokrates/proof.json','utf8'));
    try {
        await contract.submit_update(proof.proof.a, proof.proof.b, proof.proof.c , input[0], means_R, means_C, vars_R, vars_C, "Jogging", {gasLimit: 10000000}).then ((tx)=>{
            console.log(tx);
        });
    }catch (err){
        console.log(err);
    }
    console.log("finished")
});