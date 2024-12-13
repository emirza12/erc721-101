import { ethers } from "hardhat";

async function main() {
  // Deploying contracts
  const EvaNFT = await ethers.getContractFactory("EvaNFT");

  const evaNFT = await EvaNFT.deploy();

  await evaNFT.deployed();

  console.log(
    `EvaNFT deployed at  ${evaNFT.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});