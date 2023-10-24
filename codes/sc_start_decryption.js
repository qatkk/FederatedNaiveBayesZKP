const fs = require("fs");
const ethers = require('ethers');
const provider = new ethers.providers.InfuraProvider("goerli", "64f2b92ea98d47b8a584976f7f051d08");


const scheme_params =  JSON.parse(fs.readFileSync('../configs/params.json','utf8'));
const contract_addr = scheme_params.contract_addr;
const contract_ABI = fs.readFileSync('../configs/ABI.txt','utf8');
let private_key = "5f22a80a0824462fc1ed3b79306696b79dd3ed5dbb9a69287f1aa2cddb4413ef";
let wallet = new ethers.Wallet(private_key, provider);
const contract = new ethers.Contract(contract_addr, contract_ABI, wallet);


async function start_decryption() {
try {
    await contract.start_decryption({gasLimit: 5000000, gasPrice: 15000000000}).then ((tx)=>{
        provider.waitForTransaction(tx.hash); 
        console.log("The start decryption transaction hash is:", tx.hash);
    });

}catch (err){
    console.log(err);
}

}

start_decryption();