const fs = require('fs');
const {BabyJubPoint, G} = require("./BabyJubPoint");
const { string, mean } = require('mathjs');


var data; 
const number_of_model_owners = 3; 
const current_decryptor_id = 2; 


let cipher_point = new BabyJubPoint(); 
let random_point = new BabyJubPoint(); 
let output_file_dir = './decryption_output.txt'; 
let sc_input_file_dir = './sc_decryption_input.txt';

let number_of_attributes = parseInt(fs.readFileSync("./number_of_features.txt", "utf8"));
try {
    data = fs.readFileSync("encrypted.json");
  } catch (error) {
    console.error(error);
    throw error;
  }
  
const encrypted = JSON.parse(data);

let mean_cipher_primes = Array(2).fill().map(() => Array(encrypted.mean_ciphers.split(",").length/2).fill(0));
let mean_random_points = Array(2).fill().map(() => Array(encrypted.mean_ciphers.split(",").length/2).fill(0));
let mean_cipher_points =  Array(2).fill().map(() => Array(encrypted.mean_ciphers.split(",").length/2).fill(0));
try {
  data = fs.readFileSync("secret_keys.txt", "utf8");
} catch (error) {
  console.error(error);
  throw error;
}
const secret_keys = JSON.parse(data);


for (var i = 0; i < number_of_attributes; i++ ){
    x_id = 2 * i; 
    y_id = 2 * i + 1; 
    cipher_point.x = BigInt(mean_cipher_points[0][i] = encrypted.mean_ciphers.split(",")[x_id]); 
    cipher_point.y = BigInt(mean_cipher_points[1][i] = encrypted.mean_ciphers.split(",")[y_id]); 
    random_point.x = BigInt(mean_random_points[0][i] = encrypted.mean_rendoms.split(",")[x_id]); 
    random_point.y = BigInt(mean_random_points[1][i] = encrypted.mean_rendoms.split(",")[y_id]);
    cipher_point = cipher_point.sub(random_point.mul(BigInt(secret_keys.secrets[current_decryptor_id]))); 
    mean_cipher_primes[0][i] = cipher_point.x; 
    mean_cipher_primes[1][i] = cipher_point.y;
  }; 


fs.writeFileSync(output_file_dir, mean_random_points[0].join(" ") + " ",'utf8');
fs.appendFileSync(output_file_dir, mean_random_points[1].join(" ") + " ",'utf8');

fs.appendFileSync(output_file_dir, mean_cipher_points[0].join(" ") + " ",'utf8');
fs.appendFileSync(output_file_dir, mean_cipher_points[1].join(" ") + " ",'utf8');

fs.appendFileSync(output_file_dir, mean_cipher_primes[0].join(" ") + " ",'utf8');
fs.appendFileSync(output_file_dir, mean_cipher_primes[1].join(" ") + " ",'utf8');

fs.appendFileSync(output_file_dir, mean_random_points[0].join(" ") + " ",'utf8');
fs.appendFileSync(output_file_dir, mean_random_points[1].join(" ") + " ",'utf8');

fs.appendFileSync(output_file_dir, mean_cipher_points[0].join(" ") + " ",'utf8');
fs.appendFileSync(output_file_dir, mean_cipher_points[1].join(" ") + " ",'utf8');

fs.appendFileSync(output_file_dir, mean_cipher_primes[0].join(" ") + " ",'utf8');
fs.appendFileSync(output_file_dir, mean_cipher_primes[1].join(" ") + " ",'utf8');

fs.appendFileSync(output_file_dir, string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).x).split("n")[0] + " ",'utf8');
fs.appendFileSync(output_file_dir, string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).y).split("n")[0] + " ",'utf8');
fs.appendFileSync(output_file_dir, secret_keys.secrets[current_decryptor_id],'utf8');


fs.writeFileSync(sc_input_file_dir, " [ \"" + mean_cipher_points[0].join("\", \"")+ " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\"], \n [ \"" + mean_cipher_primes[0].join("\", \"") + " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\"], \n [ \" " + mean_random_points[0].join("\", \"") + " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\"], \n [ \" " + mean_cipher_points[0].join("\", \"") + " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\"], \n [ \" " + mean_cipher_primes[0].join("\", \"") + " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\"], \n [ \" " + mean_random_points[0].join("\", \"") + " ",'utf8');
fs.appendFileSync(sc_input_file_dir, " \"], \n[ \" " + string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).x).split("n")[0] + " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\", \" " +  string(G.mul(BigInt(secret_keys.secrets[current_decryptor_id])).y).split("n")[0] + " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\" ] ",'utf8');
