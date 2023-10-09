const { encrypt } = require("./encrypt");
const fs = require('fs');
const crypto = require("crypto");
const {BabyJubPoint, G, Fr} = require("./BabyJubPoint");
const { string } = require("mathjs");
const utils = require("ffjavascript").utils;



const pub_key_one_secret_key = new Fr(BigInt(utils.leBuff2int(crypto.randomBytes(32))));
const pub_key_two_secret_key = new Fr(BigInt(utils.leBuff2int(crypto.randomBytes(32))));
secret_key_file =  fs.writeFileSync('./secret_key.txt', pub_key_one_secret_key.n +  " " +  pub_key_two_secret_key.n, 'utf8');


pub_key_one = G.mul(pub_key_one_secret_key.n); 
pub_key_two = G.mul(pub_key_two_secret_key.n);
publickey = pub_key_one.add(pub_key_two); 
console.log("the x", publickey.x, " the y:", publickey.y, "\n" ); 

console.log(publickey.x +  " " +  publickey.y);
public_key_file =  fs.writeFileSync('./public_key.txt', publickey.x +  " " +  publickey.y, 'utf8');
