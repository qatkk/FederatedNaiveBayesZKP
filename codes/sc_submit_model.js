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
    let input = fs.readFileSync('./output/sc_input.txt','utf8');
    input = JSON.parse(input);
    proof = JSON.parse(fs.readFileSync('../zokrates/model_verif/proof.json','utf8'));
    try {
            await contract.submit_update(proof.proof.a, proof.proof.b, proof.proof.c , 100 , [input.random_mean_x.split(" "), input.random_mean_y.split(" ")], [input.cipher_mean_x.split(" "), input.cipher_mean_y.split(" ")], [input.random_var_x.split(" "), input.random_var_y.split(" ")], [input.cipher_var_x.split(" "), input.cipher_var_y.split(" ")], "Running", {gasLimit: 30000000, gasPrice: 5000000000}).then ((tx)=>{
            console.log("Model update transaction hash:", tx.hash);
            provider.waitForTransaction(tx.hash); 
        });
    }catch (err){
        console.log(err);
    }
}

submit_model().then(()=>{
    console.log("Local model submitted");
});