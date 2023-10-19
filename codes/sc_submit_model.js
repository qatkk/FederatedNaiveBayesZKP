const fs = require("fs");
const ethers = require('ethers');


const provider = new ethers.providers.InfuraProvider("goerli", "64f2b92ea98d47b8a584976f7f051d08");
const params =  JSON.parse(fs.readFileSync('../configs/params.json','utf8'));
const contract_addr = params.contract_addr;

const contract_ABI = fs.readFileSync('../configs/ABI.txt','utf8');
let private_key = "5f22a80a0824462fc1ed3b79306696b79dd3ed5dbb9a69287f1aa2cddb4413ef";
let wallet = new ethers.Wallet(private_key, provider);
const contract = new ethers.Contract(contract_addr, contract_ABI, wallet);

async function submit_model(){
    let input = JSON.parse(fs.readFileSync('../output/sc_input.txt','utf8'));
    proof = JSON.parse(fs.readFileSync('../zokrates/model_verif/proof.json','utf8'));
    try {
            await contract.submit_update(proof.proof.a, proof.proof.b, proof.proof.c , 100 , [input.random_mean_x.split(" "), input.random_mean_y.split(" ")], [input.cipher_mean_x.split(" "), input.cipher_mean_y.split(" ")], [input.random_var_x.split(" "), input.random_var_y.split(" ")], [input.cipher_var_x.split(" "), input.cipher_var_y.split(" ")], params.class, {gasLimit: 30000000, gasPrice: 5000000000}).then (async (tx)=>{
            console.log("Model update transaction hash:", tx.hash);
            provider.waitForTransaction(tx.hash); 
        });
    }catch(err){
        console.log(err);
    }
}

submit_model().then((res)=>{
    console.log("Submitted!");
});