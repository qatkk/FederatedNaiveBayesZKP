const fs = require('fs');
const {BabyJubPoint, G} = require("./BabyJubPoint");
const { string } = require('mathjs');
const ethers = require('ethers');
const provider = new ethers.providers.InfuraProvider("goerli", "64f2b92ea98d47b8a584976f7f051d08");
const scheme_params = JSON.parse(fs.readFileSync("../configs/params.json", "utf8"));
const contract_addr =  scheme_params.contract_addr;

const contract_ABI = fs.readFileSync('../configs/ABI.txt','utf8');
let private_key = "5f22a80a0824462fc1ed3b79306696b79dd3ed5dbb9a69287f1aa2cddb4413ef";
let wallet = new ethers.Wallet(private_key, provider);
const contract = new ethers.Contract(contract_addr, contract_ABI, wallet);
let current_decryptor_id = -1; 

async function get_decryptor_id() {
    let id = -1;
    await process.argv.forEach(function (val, index, array) {
        if (index == 2) id = val;
      });
    return id; 
}
var data; 
let cipher_point = new BabyJubPoint(); 
let random_point = new BabyJubPoint(); 
let output_file_dir = '../output/decryption_output.txt'; 
let sc_input_file_dir = '../output/sc_decryption_input.txt';


async function retrieve_partial_decrypted_varience(decryption_class) {
    let x; 
    try {
        await contract.return_varience_partial_decrypted(decryption_class, {gasLimit: 5000000}).then((tx)=>{
            x = tx.toString();
        });
    }catch (err){
        console.log(err);
    }
    return {
        "value": x
    }
}
async function retrieve_varience_random(decryption_class) {
    let x; 
    try {
        await contract.return_varience_random(decryption_class, {gasLimit: 5000000}).then((tx)=>{
            x = tx.toString();
        });
    }catch (err){
        console.log(err);
    }
    return {
        "value": x
    }
}
async function return_partial_decrypted_mu(decryption_class) {
    let x; 
    try {
        await contract.return_partial_decrypted_mu(decryption_class, {gasLimit: 5000000}).then(async (tx)=>{
            x = tx.toString();
        });
    }catch (err){
        console.log(err);
    }
    return {
        "value": x
    }
}
async function retrieve_mean_random(decryption_class) {
    let x; 
    try {
        await contract.return_mu_random(decryption_class, {gasLimit: 5000000}).then(async (tx)=>{
            x = tx.toString();
        });
    }catch (err){
        console.log(err);
    }
    return {
        "value": x
    }
}


let mean_cipher_primes = Array(2).fill().map(() => Array(scheme_params.number_of_features).fill(0));
let mean_random_points = Array(2).fill().map(() => Array(scheme_params.number_of_features).fill(0)); 
let mu_randoms; 
let mean_cipher_points = Array(2).fill().map(() => Array(scheme_params.number_of_features).fill(0));
let mu_ciphers; 
let varience_cipher_primes = Array(2).fill().map(() => Array(scheme_params.number_of_features).fill(0));
let varience_random_points = Array(2).fill().map(() => Array(scheme_params.number_of_features).fill(0));
let var_randoms; 
let varience_cipher_points = Array(2).fill().map(() => Array(scheme_params.number_of_features).fill(0));
let var_ciphers; 
try {
  data = fs.readFileSync("../output/secret_keys.txt", "utf8");
} catch (error) {
  console.error(error);
  throw error;
}
const secret_keys = JSON.parse(data);

async function decrypt(){
    current_decryptor_id = await get_decryptor_id();
    await return_partial_decrypted_mu(scheme_params.class).then((data)=>{
        mu_ciphers = data.value.split(","); 
    });
    await retrieve_mean_random(scheme_params.class).then((data)=>{
        mu_randoms = data.value.split(","); 
    });
    await retrieve_varience_random(scheme_params.class).then((data)=>{
        var_randoms = data.value.split(","); 
    });
    await retrieve_partial_decrypted_varience(scheme_params.class).then((data)=>{
        var_ciphers = data.value.split(","); 
    });
    console.log("Applying the partial decryption for MO with ID" + current_decryptor_id);
    for (var i = 0; i < scheme_params.number_of_features; i++ ){
        x_id = i; 
        y_id = i + scheme_params.number_of_features; 
        cipher_point.x = BigInt(mean_cipher_points[0][i] = mu_ciphers[x_id]); 
        cipher_point.y = BigInt(mean_cipher_points[1][i] = mu_ciphers[y_id]); 
        random_point.x = BigInt(mean_random_points[0][i] = mu_randoms[x_id]); 
        random_point.y = BigInt(mean_random_points[1][i] = mu_randoms[y_id]);
        cipher_point = cipher_point.sub(random_point.mul(BigInt(secret_keys.secrets[current_decryptor_id]))); 
        mean_cipher_primes[0][i] = cipher_point.x; 
        mean_cipher_primes[1][i] = cipher_point.y;
        cipher_point.x = BigInt(varience_cipher_points[0][i] = var_ciphers[x_id]); 
        cipher_point.y = BigInt(varience_cipher_points[1][i] = var_ciphers[y_id]); 
        random_point.x = BigInt(varience_random_points[0][i] = var_randoms[x_id]); 
        random_point.y = BigInt(varience_random_points[1][i] = var_randoms[y_id]);
        cipher_point = cipher_point.sub(random_point.mul(BigInt(secret_keys.secrets[current_decryptor_id]))); 
        varience_cipher_primes[0][i] = cipher_point.x; 
        varience_cipher_primes[1][i] = cipher_point.y;
    };
    fs.writeFileSync(output_file_dir, mean_random_points[0].join(" ") + " ",'utf8');
    fs.appendFileSync(output_file_dir, mean_random_points[1].join(" ") + " ",'utf8');

    fs.appendFileSync(output_file_dir, mean_cipher_points[0].join(" ") + " ",'utf8');
    fs.appendFileSync(output_file_dir, mean_cipher_points[1].join(" ") + " ",'utf8');

    fs.appendFileSync(output_file_dir, mean_cipher_primes[0].join(" ") + " ",'utf8');
    fs.appendFileSync(output_file_dir, mean_cipher_primes[1].join(" ") + " ",'utf8');

    fs.appendFileSync(output_file_dir, varience_random_points[0].join(" ") + " ",'utf8');
    fs.appendFileSync(output_file_dir, varience_random_points[1].join(" ") + " ",'utf8');

    fs.appendFileSync(output_file_dir, varience_cipher_points[0].join(" ") + " ",'utf8');
    fs.appendFileSync(output_file_dir, varience_cipher_points[1].join(" ") + " ",'utf8');

    fs.appendFileSync(output_file_dir, varience_cipher_primes[0].join(" ") + " ",'utf8');
    fs.appendFileSync(output_file_dir, varience_cipher_primes[1].join(" ") + " ",'utf8');

    fs.appendFileSync(output_file_dir, string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).x).split("n")[0] + " ",'utf8');
    fs.appendFileSync(output_file_dir, string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).y).split("n")[0] + " ",'utf8');
    fs.appendFileSync(output_file_dir, secret_keys.secrets[current_decryptor_id],'utf8');
    var sc_input = {
        "mean_cipher_prime_x": mean_cipher_primes[0].join(" "), 
        "mean_cipher_prime_y": mean_cipher_primes[1].join(" "), 
        "var_cipher_prime_x": varience_cipher_primes[0].join(" "), 
        "var_cipher_prime_y": varience_cipher_primes[1].join(" "), 
        "public_key_x": string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).x).split("n")[0], 
        "public_key_y": string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).y).split("n")[0]
    };
    ////// Print the output to the console 
    console.log("The partially decrypted mean parameters for the class " + scheme_params.class + " are : " + "X values: " + mean_cipher_primes[0].join("\n") +  "\nY values: " + mean_cipher_primes[1].join("\n"));
    sc_input_json = JSON.stringify(sc_input);
    
    fs.writeFileSync(sc_input_file_dir, sc_input_json, (error) => {
      if (error) {
        console.error(error);
        throw error;
        }
    });
    }
decrypt();
