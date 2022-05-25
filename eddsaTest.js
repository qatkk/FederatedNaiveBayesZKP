const eddsa = require('circomlib/src/eddsa'); 
const utils = require("ffjavascript").utils;
const crypto = require('crypto');
secKey = utils.leBuff2int(crypto.randomBytes(32));
console.log(eddsa.signMiMC(secKey.toString(), BigInt(234)));

