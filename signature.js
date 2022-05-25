const {BabyJubPoint, G, Fr} = require("./BabyJubPoint");
const mimcjs = require("circomlib/src/mimc7"); 
const crypto = require('crypto');
const { A } = require("circomlib/src/babyjub");
const { mimc7 } = require("circomlib");
const utils = require("ffjavascript").utils;
const repattern = require("@hugoalh/repattern/lib/main")
const web3 = require("web3-utils")
const { hexToBigint } = require("bigint-conversion");


function signEdDSA(msg) { 
    message = mimc7.hash(msg, 0);
    secKey = BigInt("503727473305877844506873996931912511231165373045349997878819676436274883747");
    randomValue = BigInt("915741872055174709582496649907748245746230334174847925117285815064205083888");
    pubkeyPoint = G.mul(secKey); 
    randomPoint = G.mul(randomValue);
    multiHashvalue = mimc7.multiHash([BigInt(randomPoint.x.toString()) , BigInt(pubkeyPoint.x.toString()), BigInt(message.toString())])
    console.log('js hash is ', multiHashvalue);
    sig = new Fr(randomValue) ; 
    temp = BigInt((secKey * multiHashvalue).toString()); 
    sig = sig.add(temp); 
    console.log("signature is ", sig);
    return {sig: sig,
        message: message, 
        randomPoint: randomPoint, 
        pubkeyPoint: pubkeyPoint
    };
}

function verifyEDdSA(sig, randomPoint, pubkeyPoint, message) {
    hash = mimc7.multiHash([BigInt(randomPoint.x.toString()) , BigInt(pubkeyPoint.x.toString()), BigInt(message.toString())])
    console.log("hash value", hash); 
    left = G.mul(sig.n); 
    console.log("sig point or left side ", left); 
    righTemp = pubkeyPoint.mul(hash); 
    console.log("pk . hash ", righTemp); 
    right = randomPoint.add(righTemp); 

    console.log("right hand", right, "\n", "left hand", left);
    return right.x == left.x ;
}

exports.verifyEDdSA = verifyEDdSA;
exports.signEdDSA = signEdDSA;