const utils = require("ffjavascript").utils;
const fs = require("fs");
const web3 = require("web3-utils"); 
const ethers = require('ethers');
const provider = new ethers.providers.InfuraProvider("goerli", "64f2b92ea98d47b8a584976f7f051d08");
const contract_addr =  fs.readFileSync('../configs/contract_addr.txt','utf8');
const { promisify } = require('util');
const { json } = require("mathjs");
const sleep = promisify(setTimeout);

const contract_ABI = fs.readFileSync('../configs/ABI.txt','utf8');
let private_key = "5f22a80a0824462fc1ed3b79306696b79dd3ed5dbb9a69287f1aa2cddb4413ef";
let wallet = new ethers.Wallet(private_key, provider);
const contract = new ethers.Contract(contract_addr, contract_ABI, wallet);


public_key =  fs.readFileSync('../output/pubkey_compact.txt','utf8');
async function submit_pulic_key() {
    try {
        await contract.submit_pubkey(BigInt(public_key.toString()), {gasLimit: 30000000, gasPrice: 3000000000}).then ((tx)=>{
            console.log("Public key submission transaction hash:", tx.hash);
            provider.waitForTransaction(tx.hash); 
        });
    }catch (err){
        console.log(err);
    }

}

submit_pulic_key().then(()=>{
    console.log("Public key submitted!");
});