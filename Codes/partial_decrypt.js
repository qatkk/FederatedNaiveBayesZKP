const fs = require('fs');
const {BabyJubPoint, G} = require("./BabyJubPoint");
const { string } = require('mathjs');
const utils = require("ffjavascript").utils;
const web3 = require("web3-utils"); 
const ethers = require('ethers');
const provider = new ethers.providers.InfuraProvider("goerli", "64f2b92ea98d47b8a584976f7f051d08");
const contract_addr =  fs.readFileSync('./configs/contract_addr.txt','utf8');
const { promisify } = require('util');
const sleep = promisify(setTimeout);

const contract_ABI = fs.readFileSync('./ABI.txt','utf8');
let private_key = "5f22a80a0824462fc1ed3b79306696b79dd3ed5dbb9a69287f1aa2cddb4413ef";
let wallet = new ethers.Wallet(private_key, provider);
const contract = new ethers.Contract(contract_addr, contract_ABI, wallet);



var data; 
const current_decryptor_id = 2; 
const decryption_class = "Running";

let cipher_point = new BabyJubPoint(); 
let random_point = new BabyJubPoint(); 
let output_file_dir = './output/decryption_output.txt'; 
let sc_input_file_dir = './output/sc_decryption_input.txt';


async function retrieve_ciphertext() {
try {
    await contract.varience_partial_decrypted(decryption_class, 0, 14 , {gasLimit: 5000000}).then ((tx)=>{
      provider.waitForTransaction(tx.hash); 
      console.log(tx);
      // return({"data":tx});
    });
}catch (err){
    console.log(err);
}

}

retrieve_ciphertext().then(async ()=>{
    console.log("the point x value is ");
});
// let number_of_attributes = parseInt(fs.readFileSync("./configs/number_of_features.txt", "utf8"));
// try {
//     data = fs.readFileSync("./output/encrypted.json");
//   } catch (error) {
//     console.error(error);
//     throw error;
//   }
  
// const encrypted = JSON.parse(data);

// let mean_cipher_primes = Array(2).fill().map(() => Array(encrypted.mean_ciphers.split(",").length/2).fill(0));
// let mean_random_points = Array(2).fill().map(() => Array(encrypted.mean_ciphers.split(",").length/2).fill(0));
// let mean_cipher_points =  Array(2).fill().map(() => Array(encrypted.mean_ciphers.split(",").length/2).fill(0));
// try {
//   data = fs.readFileSync("output/secret_keys.txt", "utf8");
// } catch (error) {
//   console.error(error);
//   throw error;
// }
// const secret_keys = JSON.parse(data);


// for (var i = 0; i < number_of_attributes; i++ ){
//     x_id = 2 * i; 
//     y_id = 2 * i + 1; 
//     cipher_point.x = BigInt(mean_cipher_points[0][i] = encrypted.mean_ciphers.split(",")[x_id]); 
//     cipher_point.y = BigInt(mean_cipher_points[1][i] = encrypted.mean_ciphers.split(",")[y_id]); 
//     random_point.x = BigInt(mean_random_points[0][i] = encrypted.mean_rendoms.split(",")[x_id]); 
//     random_point.y = BigInt(mean_random_points[1][i] = encrypted.mean_rendoms.split(",")[y_id]);
//     cipher_point = cipher_point.sub(random_point.mul(BigInt(secret_keys.secrets[current_decryptor_id]))); 
//     mean_cipher_primes[0][i] = cipher_point.x; 
//     mean_cipher_primes[1][i] = cipher_point.y;
//   }; 


// fs.writeFileSync(output_file_dir, mean_random_points[0].join(" ") + " ",'utf8');
// fs.appendFileSync(output_file_dir, mean_random_points[1].join(" ") + " ",'utf8');

// fs.appendFileSync(output_file_dir, mean_cipher_points[0].join(" ") + " ",'utf8');
// fs.appendFileSync(output_file_dir, mean_cipher_points[1].join(" ") + " ",'utf8');

// fs.appendFileSync(output_file_dir, mean_cipher_primes[0].join(" ") + " ",'utf8');
// fs.appendFileSync(output_file_dir, mean_cipher_primes[1].join(" ") + " ",'utf8');

// fs.appendFileSync(output_file_dir, mean_random_points[0].join(" ") + " ",'utf8');
// fs.appendFileSync(output_file_dir, mean_random_points[1].join(" ") + " ",'utf8');

// fs.appendFileSync(output_file_dir, mean_cipher_points[0].join(" ") + " ",'utf8');
// fs.appendFileSync(output_file_dir, mean_cipher_points[1].join(" ") + " ",'utf8');

// fs.appendFileSync(output_file_dir, mean_cipher_primes[0].join(" ") + " ",'utf8');
// fs.appendFileSync(output_file_dir, mean_cipher_primes[1].join(" ") + " ",'utf8');

// fs.appendFileSync(output_file_dir, string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).x).split("n")[0] + " ",'utf8');
// fs.appendFileSync(output_file_dir, string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).y).split("n")[0] + " ",'utf8');
// fs.appendFileSync(output_file_dir, secret_keys.secrets[current_decryptor_id],'utf8');


// fs.writeFileSync(sc_input_file_dir, " [ \"" + mean_cipher_points[0].join("\", \"")+ " ",'utf8');
// fs.appendFileSync(sc_input_file_dir, "\"], \n [ \"" + mean_cipher_primes[0].join("\", \"") + " ",'utf8');
// fs.appendFileSync(sc_input_file_dir, "\"], \n [ \" " + mean_random_points[0].join("\", \"") + " ",'utf8');
// fs.appendFileSync(sc_input_file_dir, "\"], \n [ \" " + mean_cipher_points[0].join("\", \"") + " ",'utf8');
// fs.appendFileSync(sc_input_file_dir, "\"], \n [ \" " + mean_cipher_primes[0].join("\", \"") + " ",'utf8');
// fs.appendFileSync(sc_input_file_dir, "\"], \n [ \" " + mean_random_points[0].join("\", \"") + " ",'utf8');
// fs.appendFileSync(sc_input_file_dir, " \"], \n[ \" " + string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).x).split("n")[0] + " ",'utf8');
// fs.appendFileSync(sc_input_file_dir, "\", \" " +  string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).y).split("n")[0] + " ",'utf8');
// fs.appendFileSync(sc_input_file_dir, "\" ] ",'utf8');
