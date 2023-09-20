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
let sc_input_file_dir = "./sc_input.txt"
// The actual data 
let vars = data.slice(data.length - (3 + number_of_attributes), data.length - 3);
let means = data.slice(data.length - (3 + number_of_attributes) - number_of_attributes, data.length - 3 -number_of_attributes);

// Random generated 
// let vars = Array(number_of_attributes).fill(0);
// let means = Array(number_of_attributes).fill(0);
// for ( let i = 0; i<number_of_attributes; i++ ){
//     vars[i] = utils.leBuff2int(crypto.randomBytes(32));
//     means[i] = utils.leBuff2int(crypto.randomBytes(32));
// }

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


fs.appendFileSync('./data.txt', message_mean.join(" ") + " ",'utf8');

fs.appendFileSync('./data.txt', random_mean[0].join(" ") + " ",'utf8');
fs.appendFileSync('./data.txt', random_mean[1].join(" ") + " ",'utf8');

fs.appendFileSync('./data.txt', cipher_mean[0].join(" ") + " ",'utf8');
fs.appendFileSync('./data.txt', cipher_mean[1].join(" ") + " ",'utf8');

fs.appendFileSync('./data.txt', message_var.join(" ") + " ",'utf8');
fs.appendFileSync('./data.txt', random_var[0].join(" ") + " ",'utf8');
fs.appendFileSync('./data.txt', random_var[1].join(" ") + " ",'utf8');

fs.appendFileSync('./data.txt', cipher_var[0].join(" ") + " ",'utf8');
fs.appendFileSync('./data.txt', cipher_var[1].join(" ") + " ",'utf8');

fs.appendFileSync('./data.txt', public_key.x + " " + public_key.y + " ",'utf8');
fs.appendFileSync('./data.txt', random_value.n.toString(),'utf8');





fs.appendFileSync(sc_input_file_dir, " [ [ \"" + random_mean[0].join("\", \"")+ " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\"], \n [ \"" + random_mean[1].join("\", \"") + " ",'utf8');

fs.appendFileSync(sc_input_file_dir, "\"] ], \n [ [ \"" + cipher_mean[0].join("\", \"") + " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\"], \n [ \"" + cipher_mean[1].join("\", \"") + " ",'utf8');

fs.appendFileSync(sc_input_file_dir, "\"] ], \n [ [ \" " + random_var[0].join("\", \"") + " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\"], \n [ \" " + random_var[1].join("\", \"") + " ",'utf8');

fs.appendFileSync(sc_input_file_dir, "\"] ], \n [ [ \" " + cipher_var[0].join("\", \"") + " ",'utf8');
fs.appendFileSync(sc_input_file_dir, "\"], \n [ \" " + cipher_var[1].join("\", \"") + " ",'utf8');

fs.appendFileSync(sc_input_file_dir, "\" ]  ]",'utf8');



var encrypted = {
    "mean_message": message_mean.join(),
    "mean_rendoms": random_mean.join(), 
    "mean_ciphers": cipher_mean.join(),
    "var_message": message_var.join(),
    "var_randoms": random_var.join(), 
    "var_ciphers": cipher_var.join()
}; 

var plain_text = {
    "means": means.join(), 
    "vars": vars.join()
};


encrypted_txt = JSON.stringify(encrypted);

// writing the JSON string content to a file
fs.writeFile("encrypted.json", encrypted_txt, (error) => {
  // throwing the error
  // in case of a writing problem
  if (error) {
    // logging the error
    console.error(error);

    throw error;
    }
    console.log("data.json written correctly");
});

plain_text = JSON.stringify(plain_text);

// writing the JSON string content to a file
fs.writeFile("feature_values.json", plain_text, (error) => {
  // throwing the error
  // in case of a writing problem
  if (error) {
    // logging the error
    console.error(error);

    throw error;
    }
    console.log("features written correctly");
});