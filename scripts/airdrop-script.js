const hre = require("hardhat");
const admin_address = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
const name = "Tollan"
const symbol = "TLN"


async function main() {
    const Airdrop = await hre.ethers.getContractFactory("Airdrop");
    // Add constructor values for nft and admin address
    const airdrop = await Airdrop.deploy(name, symbol, admin_address);
    await airdrop.deployed();
    console.log("Airdrop contract deployed to:", airdrop.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
