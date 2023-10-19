const hre = require("hardhat");
const fs = require("fs");


async function main() {
    let scheme_params = JSON.parse(fs.readFileSync('./configs/params.json','utf8'));
    const number_of_features =  scheme_params.number_of_features;
    const number_of_MOs =  scheme_params.number_of_MOs;
    const FLSC = await ethers.getContractFactory("FLSC");

  // Start deployment, returning a promise that resolves to a contract object
    const FLSC_inst = await FLSC.deploy(number_of_MOs, number_of_features, funding = 0, deposit = 0);
    console.log("Contract deployed to address: \n", FLSC_inst.address, "\nthe number of features are: ", number_of_features, "\nthe batch_size is set to:", scheme_params.batch_size,  "\nand the number of MOs are:", number_of_MOs );
    scheme_params.contract_addr = FLSC_inst.address;
    fs.writeFileSync('./configs/params.json',JSON.stringify(scheme_params), 'utf8');
    await hre.artifacts.readArtifact("./contracts/FLSC.sol:FLSC").then((artifact)=> {
      fs.writeFileSync("./configs/ABI.txt", JSON.stringify(artifact.abi), "utf8");
  });
}

main()
 .then(() => process.exit(0))
 .catch(error => {
   console.error(error);
   process.exit(1);
 });
