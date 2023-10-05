const utils = require("ffjavascript").utils;
const fs = require("fs");
const web3 = require("web3-utils"); 
const ethers = require('ethers');
const provider = new ethers.providers.InfuraProvider("goerli", "64f2b92ea98d47b8a584976f7f051d08");
const contract_addr =  fs.readFileSync('./configs/contract_addr.txt','utf8');
const { promisify } = require('util');
const { json } = require("mathjs");
const sleep = promisify(setTimeout);

const contract_ABI = fs.readFileSync('./ABI.txt','utf8');
let private_key = "5f22a80a0824462fc1ed3b79306696b79dd3ed5dbb9a69287f1aa2cddb4413ef";
let wallet = new ethers.Wallet(private_key, provider);
const contract = new ethers.Contract(contract_addr, contract_ABI, wallet);


async function submit_model() {
    let input = fs.readFileSync('./output/sc_decryption_input.txt','utf8');
    input = JSON.parse(input);
    proof = JSON.parse(fs.readFileSync('../zokrates/decryption/proof.json','utf8'));
    try {
            await contract.submit_decryption(proof.proof.a, proof.proof.b, proof.proof.c , input.mean_cipher_prime_x.split(" "), input.mean_cipher_prime_y.split(" "), input.var_cipher_prime_x.split(" "), input.var_cipher_prime_y.split(" "),  [input.public_key_x, input.public_key_y],  "Running", {gasLimit: 30000000}).then ((tx)=>{
            console.log("Decryption transaction hash:", tx.hash);
            provider.waitForTransaction(tx.hash); 
        });
    }catch (err){
        console.log(err);
    }
}

submit_model().then(()=>{
    console.log("Decryption submitted");
});