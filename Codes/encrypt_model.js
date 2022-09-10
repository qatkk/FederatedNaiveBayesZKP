const { encrypt } = require("./encrypt");
const fs = require('fs');
const crypto = require("crypto");
const {BabyJubPoint, G, Fr} = require("./BabyJubPoint");
const utils = require("ffjavascript").utils;


public_key_temp = fs.readFileSync("./public_key.txt", "utf8"); 
public_key_temp = public_key_temp.split(" "); 
public_key = new BabyJubPoint(public_key_temp[0], public_key_temp[1]); 

let number_of_attributes = parseInt(fs.readFileSync("./number_of_features.txt", "utf8"));

data =  fs.readFileSync('./data.txt','utf8');
data = data.split(" "); 
// Seperate the means and variances from the data 

let vars = data.slice(data.length - (3 + number_of_attributes), data.length - 3);
let means = data.slice(data.length - (3 + number_of_attributes) - number_of_attributes, data.length - 3 -number_of_attributes);


const random_value = new Fr(BigInt(utils.leBuff2int(crypto.randomBytes(32))));
let message_mean = []; 
let random_mean = []; 
let cipher_mean = []; 

let message_var = []; 
let random_var = []; 
let cipher_var = []; 


for (i = 0 ; i< number_of_attributes * 2; i++ ) {
    if (i<number_of_attributes ){
        encrypted = encrypt(random_value.n, means[i], public_key); 
        message_mean.push(encrypted.Message.x); 
        message_mean.push(encrypted.Message.y);
        random_mean.push(encrypted.Random.x); 
        random_mean.push(encrypted.Random.y); 
        cipher_mean.push(encrypted.Cipher.x); 
        cipher_mean.push(encrypted.Cipher.y); 
     }
    else {
        encrypted = encrypt(random_value.n, vars[i-number_of_attributes], public_key); 
        message_var.push(encrypted.Message.x); 
        message_var.push(encrypted.Message.y);
        random_var.push(encrypted.Random.x); 
        random_var.push(encrypted.Random.y); 
        cipher_var.push(encrypted.Cipher.x); 
        cipher_var.push(encrypted.Cipher.y);     
    }
}


fs.appendFileSync('./data.txt', message_mean.join(" "),'utf8');
fs.appendFileSync('./data.txt', " ",'utf8');
fs.appendFileSync('./data.txt', random_mean.join(" "),'utf8');
fs.appendFileSync('./data.txt', " ",'utf8');
fs.appendFileSync('./data.txt', cipher_mean.join(" "),'utf8');
fs.appendFileSync('./data.txt', " ",'utf8');
fs.appendFileSync('./data.txt', message_var.join(" "),'utf8');
fs.appendFileSync('./data.txt', " ",'utf8');
fs.appendFileSync('./data.txt', random_var.join(" "),'utf8');
fs.appendFileSync('./data.txt', " ",'utf8');
fs.appendFileSync('./data.txt', cipher_var.join(" "),'utf8');
fs.appendFileSync('./data.txt', " ",'utf8');
fs.appendFileSync('./data.txt', public_key.x + " " + public_key.y + " ",'utf8');
fs.appendFileSync('./data.txt', random_value.n.toString(),'utf8');


fs.appendFileSync('./sc_input.txt', random_mean.join(" "),'utf8');
fs.appendFileSync('./sc_input.txt', " ",'utf8');
fs.appendFileSync('./sc_input.txt', cipher_mean.join(" "),'utf8');
fs.appendFileSync('./sc_input.txt', " ",'utf8');
fs.appendFileSync('./sc_input.txt', random_var.join(" "),'utf8');
fs.appendFileSync('./sc_input.txt', " ",'utf8');
fs.appendFileSync('./sc_input.txt', cipher_var.join(" "),'utf8');
fs.appendFileSync('./sc_input.txt', " ",'utf8');