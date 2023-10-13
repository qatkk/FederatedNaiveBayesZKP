const hre = require("hardhat");
const fs = require("fs");


async function main() {
    const number_of_features =  fs.readFileSync('./configs/number_of_features.txt','utf8');
    const number_of_entities =  fs.readFileSync('./configs/number_of_MOs.txt','utf8');
    const FLSC = await ethers.getContractFactory("FLSC");

  // Start deployment, returning a promise that resolves to a contract object
    const FLSC_inst = await FLSC.deploy(number_of_entities, number_of_features, funding = 0, deposit = 0);
    console.log("Contract deployed to address:", FLSC_inst.address);
    fs.writeFileSync('./configs/contract_addr.txt',FLSC_inst.address, 'utf8');
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
