const fs = require('fs');
const {BabyJubPoint, G} = require("./BabyJubPoint");
const { string } = require('mathjs');
const utils = require("ffjavascript").utils;




// let data_one = fs.readFileSync("~/Desktop/Data/data.txt", 'utf8').split(" ");
// console.log(data_one); 
// let data_two = fs.readFileSync('~/Desktop/Data/data 2.txt', 'utf8').split(" ");
// console.log("\n ", data_two); 
let temp_point_one = new BabyJubPoint(BigInt(18203872954306560489542852025296164413107021891842238638198663402947211088384), BigInt(2428401009532410492952310972041292804073148738245972142462701457911916394006));
let temp_point_two = new BabyJubPoint(BigInt(18025965142369693138968466443811854993508959643120056287417631341767040771436), BigInt(14568451586742990885759453544377683763928050607976935438465522717335242808830));

console.log(temp_point_one.add(temp_point_two));

