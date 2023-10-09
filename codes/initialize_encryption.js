const fs = require('fs');
const crypto = require("crypto");
const {BabyJubPoint, G, Fr} = require("./BabyJubPoint");
const utils = require("ffjavascript").utils;


let secret_keys_dir = "./output/secret_keys.txt";
let public_keys_dir = "./output/public_key.txt";
let public_key_compact_dir = "./output/pubkey_compact.txt";
let number_of_parties = fs.readFileSync('./configs/number_of_MOs.txt','utf8');


let secret_keys = [number_of_parties];
let secret_keys_infield = [number_of_parties]; 
let total_public_key = new BabyJubPoint();
for (i = 0; i<number_of_parties; i++) {
    secret_keys_infield [i] = new Fr (BigInt(utils.leBuff2int(crypto.randomBytes(32))));
    secret_keys [i] = secret_keys_infield[i].n.toString();
    total_public_key = total_public_key.add(G.mul(BigInt(secret_keys[i])));
}
let secret_key_data = {
    "secrets": secret_keys
};

fs.writeFileSync(secret_keys_dir, JSON.stringify(secret_key_data), "utf8");
fs.writeFileSync(public_keys_dir, [total_public_key.x, total_public_key.y].join(" "), "utf8");
fs.writeFileSync(public_key_compact_dir, utils.leBuff2int(total_public_key.compress()).toString(), 'utf8');