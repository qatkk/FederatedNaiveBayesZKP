const { encrypt } = require("./encrypt");
const fs = require('fs');
const crypto = require("crypto");
const {BabyJubPoint, G, Fr} = require("./BabyJubPoint");
const { json, sec } = require("mathjs");
const utils = require("ffjavascript").utils;



let number_of_parties = 3

let secret_keys = [number_of_parties];
let secret_keys_infield = [number_of_parties]; 
let total_secret_key = new Fr(BigInt(0));

for (i = 0; i<number_of_parties; i++) {
    secret_keys_infield [i] = new Fr (BigInt(utils.leBuff2int(crypto.randomBytes(32))));
    secret_keys [i] = secret_keys_infield[i].n.toString();
    total_secret_key = total_secret_key.add(secret_keys_infield[i]);
}
let secret_key_data = {
    "secrets": secret_keys, 
    "total": total_secret_key.n.toString()
}
const public_key = G.mul(total_secret_key.n);

fs.writeFileSync("./secret_keys.txt", JSON.stringify(secret_key_data), "utf8");
fs.writeFileSync("./public_key.txt", [public_key.x, public_key.y].join(" "), "utf8");
fs.writeFileSync("./pubkey_compact.txt", utils.leBuff2int(public_key.compress()).toString(), 'utf8');