// npx hardhat run --network hamster ./scripts/deploy.js
// npx hardhat verify --network goerli --constructor-args ./scripts/arguments.js 0x78B534F2B83863C21FabE5447e7af4ee71ddfC55

let voting = '0x78B534F2B83863C21FabE5447e7af4ee71ddfC55'

async function deployContract(address, name, ...params) {
    const contractFactory = await ethers.getContractFactory(name);
    
    if (!address) {
        const contract = await contractFactory.deploy(...params);
        await contract.deployed();
        return contract
    } else {
        return contractFactory.attach(address)
    }
}

async function deploy_Voting(owner) {
    console.log('owner', owner)
    voting = await deployContract(voting, 'contractDN', [owner])
    console.log('voting:', voting.address);
}

async function main() {
    const signer = await ethers.getSigner()
    const owner = signer.address;
    await deploy_Voting(owner)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
