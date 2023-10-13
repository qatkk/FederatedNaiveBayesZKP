const { encrypt } = require("./encrypt");
const fs = require('fs');
const crypto = require("crypto");
const {BabyJubPoint, Fr} = require("./BabyJubPoint");
const utils = require("ffjavascript").utils;


public_key_temp = fs.readFileSync("../output/public_key.txt", "utf8"); 
public_key_temp = public_key_temp.split(" "); 
let data_dir = "../output/data.txt";
let sc_input_file_dir = "../output/sc_input.txt";

public_key = new BabyJubPoint(public_key_temp[0], public_key_temp[1]); 

let number_of_attributes = parseInt(fs.readFileSync("../configs/number_of_features.txt", "utf8"));

data =  fs.readFileSync(data_dir,'utf8');
data = data.split(" "); 
let vars = data.slice(data.length - (3 + number_of_attributes), data.length - 3);
let means = data.slice(data.length - (3 + number_of_attributes) - number_of_attributes, data.length - 3 -number_of_attributes);



const random_value = new Fr(BigInt(utils.leBuff2int(crypto.randomBytes(32))));
let message_mean = []; 

let random_mean = Array(2).fill().map(() => Array(number_of_attributes).fill(0));
let cipher_mean = Array(2).fill().map(() => Array(number_of_attributes).fill(0));
let message_var = []; 
let random_var = Array(2).fill().map(() => Array(number_of_attributes).fill(0));
let cipher_var = Array(2).fill().map(() => Array(number_of_attributes).fill(0));


for (i = 0 ; i< number_of_attributes * 2; i++ ) {
    if (i<number_of_attributes ){
        encrypted = encrypt(random_value.n, means[i], public_key); 
        message_mean.push(encrypted.Message.x); 
        message_mean.push(encrypted.Message.y);
        random_mean[0][i] = (encrypted.Random.x); 
        random_mean[1][i] = (encrypted.Random.y); 
        cipher_mean[0][i] = (encrypted.Cipher.x); 
        cipher_mean[1][i] = (encrypted.Cipher.y); 
     }
    else {
        encrypted = encrypt(random_value.n, vars[i-number_of_attributes], public_key); 
        message_var.push(encrypted.Message.x); 
        message_var.push(encrypted.Message.y);
        random_var[0][i-number_of_attributes] = (encrypted.Random.x); 
        random_var[1][i-number_of_attributes] = (encrypted.Random.y); 
        cipher_var[0][i-number_of_attributes] = (encrypted.Cipher.x); 
        cipher_var[1][i-number_of_attributes] = (encrypted.Cipher.y);     
    }
}


fs.appendFileSync(data_dir, message_mean.join(" ") + " ",'utf8');

fs.appendFileSync(data_dir, random_mean[0].join(" ") + " ",'utf8');
fs.appendFileSync(data_dir, random_mean[1].join(" ") + " ",'utf8');

fs.appendFileSync(data_dir, cipher_mean[0].join(" ") + " ",'utf8');
fs.appendFileSync(data_dir, cipher_mean[1].join(" ") + " ",'utf8');

fs.appendFileSync(data_dir, message_var.join(" ") + " ",'utf8');
fs.appendFileSync(data_dir, random_var[0].join(" ") + " ",'utf8');
fs.appendFileSync(data_dir, random_var[1].join(" ") + " ",'utf8');

fs.appendFileSync(data_dir, cipher_var[0].join(" ") + " ",'utf8');
fs.appendFileSync(data_dir, cipher_var[1].join(" ") + " ",'utf8');

fs.appendFileSync(data_dir, public_key.x + " " + public_key.y + " ",'utf8');
fs.appendFileSync(data_dir, random_value.n.toString(),'utf8');





var sc_input = {
    "random_mean_x": random_mean[0].join(" "), 
    "random_mean_y": random_mean[1].join(" "), 
    "cipher_mean_x": cipher_mean[0].join(" "), 
    "cipher_mean_y": cipher_mean[1].join(" "), 
    "random_var_x": random_var[0].join(" "), 
    "random_var_y": random_var[1].join(" "), 
    "cipher_var_x": cipher_var[0].join(" "), 
    "cipher_var_y": cipher_var[1].join(" ")
};

sc_input_json = JSON.stringify(sc_input);

fs.writeFileSync(sc_input_file_dir, sc_input_json, (error) => {
  if (error) {
    console.error(error);
    throw error;
    }
});