const {BabyJubPoint, G, Fr, Frr, randFr, subOrder, order} = require("./BabyJubPoint");



function encrypt(random, message, pubkey) {
    random_point = G.mul(BigInt(random.toString())); 
    message_point = G.mul(BigInt(message.toString())); 
    cipher_text = (pubkey.mul(BigInt(random.toString()))).add(message_point);
    return {
        "Random": random_point, 
        "Cipher": cipher_text, 
        "Message": message_point
    }
}


exports.encrypt = encrypt; 