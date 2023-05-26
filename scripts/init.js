const helpers = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("ethers");
const hre = require("hardhat");

async function init() {
  //const provider = hre.ethers.provider; // Use the Hardhat provider
  const address = "0x674c8b3E81f4a2dc6da605593184fd3d57D29722";

  await helpers.setBalance(address, 1100 * 1e18);

  console.log(address);

  // Get the balance of the Ethereum address

  //const balance = await hre.ethers.getBalance(address);
  const balance = await hre.ethers.provider.getBalance(address);
  console.log(balance);

  /* provider.getBalance(address).then((balance) => {
    // convert a currency unit from wei to ether
    const balanceInEth = ethers.utils.formatEther(balance);
    console.log(balance: ${balanceInEth} ETH);
  }); */
}

init()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
