const { ethers } = require("hardhat");

async function main() {
  // 1 LINK is sufficient for this example
  const linkAmount = "4";
  // Set your consumer contract address. This contract will
  // be added as an approved consumer of the subscription.
  const consumer = "0xE56eB855BBa5A7A1c9f1C15FBb84c689028261bf";

  // Network-specific configs
  // Sepolia LINK 0x779877A7B0D9E8603169DdbD7836e478b4624789
  // See https://docs.chain.link/resources/link-token-contracts
  // to find the LINK token contract address for your network.
  const linkTokenAddress = "0x779877A7B0D9E8603169DdbD7836e478b4624789";
  // Sepolia billing registry: 0x3c79f56407DCB9dc9b852D139a317246f43750Cc
  // See https://docs.chain.link/chainlink-functions/supported-networks
  // for a list of supported networks and registry addresses.
  const functionsBillingRegistryProxy =
    "0x3c79f56407DCB9dc9b852D139a317246f43750Cc";

  const RegistryFactory = await ethers.getContractFactory(
    "src/backend/contracts/dev/functions/FunctionsBillingRegistry.sol:FunctionsBillingRegistry"
  );
  const registry = await RegistryFactory.attach(functionsBillingRegistryProxy);

  const createSubscriptionTx = await registry.createSubscription();
  const createSubscriptionReceipt = await createSubscriptionTx.wait(1);
  const subscriptionId =
    createSubscriptionReceipt.events[0].args["subscriptionId"].toNumber();
  console.log(`Subscription created with ID: ${subscriptionId}`);

  //Get the amount to fund, and ensure the wallet has enough funds
  const juelsAmount = ethers.utils.parseUnits(linkAmount);
  const LinkTokenFactory = await ethers.getContractFactory("lib/chainlink-brownie-contracts/contracts/src/v0.4/LinkToken.sol:LinkToken");
  const linkToken = await LinkTokenFactory.attach(linkTokenAddress);

  const accounts = await ethers.getSigners();
  const signer = accounts[0];

  // Check for a sufficent LINK balance to fund the subscription
  const balance = await linkToken.balanceOf(signer.address);
  if (juelsAmount.gt(balance)) {
    throw Error(`Insufficent LINK balance`);
  }

  console.log(`Funding with ` + juelsAmount + ` Juels (1 LINK = 10^18 Juels)`);
  const fundTx = await linkToken.transferAndCall(
    functionsBillingRegistryProxy,
    juelsAmount,
    ethers.utils.defaultAbiCoder.encode(["uint64"], [subscriptionId])
  );
  await fundTx.wait(1);
  console.log(
    `Subscription ${subscriptionId} funded with ${juelsAmount} Juels (1 LINK = 10^18 Juels)`
  );

  //Authorize deployed contract to use new subscription
  console.log(
    `Adding consumer contract address ${consumer} to subscription ${subscriptionId}`
  );
  const addTx = await registry.addConsumer(subscriptionId, consumer);
  await addTx.wait(1);
  console.log(`Authorized consumer contract: ${consumer}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });