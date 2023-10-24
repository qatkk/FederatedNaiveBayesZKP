const fs = require('fs');
const {BabyJubPoint, G} = require("./BabyJubPoint");
const ethers = require("ethers");
const math = require("math");
const provider = new ethers.providers.InfuraProvider("goerli", "64f2b92ea98d47b8a584976f7f051d08");
const scheme_params = JSON.parse(fs.readFileSync("../configs/params.json", "utf8"));
const contract_addr =  scheme_params.contract_addr;

const contract_ABI = fs.readFileSync('../configs/ABI.txt','utf8');
let private_key = "5f22a80a0824462fc1ed3b79306696b79dd3ed5dbb9a69287f1aa2cddb4413ef";
let wallet = new ethers.Wallet(private_key, provider);
const contract = new ethers.Contract(contract_addr, contract_ABI, wallet);
const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
  });


async function return_partial_decrypted_mu(decryption_class) {
    let x; 
    try {
        await contract.return_partial_decrypted_mu(decryption_class, {gasLimit: 5000000}).then(async (tx)=>{
            x = tx.toString();
        });
    }catch (err){
        console.log(err);
    }
    return {
        "value": x
    }
}


function transpose(array) {
    return Object.keys(array[0]).map(function(column) {
        return array.map(function(row) { return row[column]; });
    });
}
let  submitted_model_parameters = JSON.parse(fs.readFileSync("../output/model_params.json", 'utf8'));
async function main(){
    let mu_points;
    let mu_values = [];
    let mu =0;
    let point = new BabyJubPoint();
    await return_partial_decrypted_mu(scheme_params.class).then((data)=>{
        mu_points = data.value.split(","); 
    });
    for (let feature = 0; feature<scheme_params.number_of_features; feature++){
        point.x = mu_points[feature]; 
        point.y = mu_points[feature + scheme_params.number_of_features];
        console.log("Point of feature " + feature +  " is" + "\n x:" + point.x + "\n y:" + point.y);
        while(!G.mul(BigInt(mu)).equal(point)) mu++;
        console.log("Feature value is " + mu); 
        mu_values.push(mu);
        mu = 0;
    };
    console.log("Decrypted mean values are ", mu_values);
    let summed_mean_parameters = []; 
    let transposed = transpose(submitted_model_parameters.Means);
    for (let i =0; i<scheme_params.number_of_features; i++){
        summed_mean_parameters.push(math.sum(transposed[i]));
    }
    console.log("The summation of the submitted means are:" ,summed_mean_parameters);
    process.exit(0);
};


main().then(
    console.log("Decryption started!")
);