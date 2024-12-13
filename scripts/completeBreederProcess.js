// scripts/completeBreederProcess.js
task("completeBreederProcess", "Registers as breeder, declares an animal, and lists it for sale")
  .addParam("address", "The wallet address to register and use")
  .addParam("name", "The name of the animal")
  .addParam("price", "The price at which the animal will be listed for sale in wei")
  .setAction(async (taskArgs, hre) => {
    const { ethers } = hre;
    const contractAddress = "0x9d6CaBD1D183A37946adc2bBf0bAE368143F1DFF";
    const EvaNFT = await ethers.getContractAt("EvaNFT", contractAddress, (await ethers.getSigners())[0]);

    console.log("Registering as a breeder...");
    const txRegister = await EvaNFT.registerMeAsBreeder({ value: ethers.utils.parseUnits("0", "ether") });
    await txRegister.wait();
    console.log("Registration as breeder completed.");

    console.log("Declaring new animal...");
    const txDeclare = await EvaNFT.declareAnimal(0, 3, false, taskArgs.name);
    const receiptDeclare = await txDeclare.wait();
    const animalId = receiptDeclare.events.filter(x => x.event === "Transfer")[0].args.tokenId.toString();
    console.log(`Animal declared with ID: ${animalId}`);

    const txReproduce =  await EvaNFT.offerForReproduction(animalId, 1);
    console.log('Reproduction offer created', EvaNFT.canReproduce(animalId));

    //console.log(`Offering animal ID ${animalId} for sale at ${taskArgs.price} wei...`);
    //const txOffer = await EvaNFT.offerForSale(animalId, taskArgs.price);
    //await txOffer.wait();
    //console.log(`Animal ID ${animalId} is now for sale.`);
  });

module.exports = {};
