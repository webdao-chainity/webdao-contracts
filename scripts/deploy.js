// npx hardhat run --network hamster ./scripts/deploy.js
// npx hardhat verify --network goerli --constructor-args ./scripts/arguments.js 0x78B534F2B83863C21FabE5447e7af4ee71ddfC55

let voting = '0x78B534F2B83863C21FabE5447e7af4ee71ddfC55'
let voteNft = '0xf1D9A0501dd8616D8875b5E04e17D06dF4195458'

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

async function deployVoting(owner) {
    voting = await deployContract(voting, 'contractDN', [owner])
    console.log('voting:', voting.address);
}

async function deployNFT() {
    voteNft = await deployContract(voteNft, 'VoteNFT')
    console.log('voteNft:', voteNft.address);
}

async function setupRole() {
    await voteNft.addRole('CEO', 1)
    await voteNft.addRole('CTO', 2)
    await voteNft.addRole('CMO', 3)
}

async function mint(owner) {
    await voteNft.safeMint('CEO', owner, 10)
}

async function main() {
    const signer = await ethers.getSigner()
    const owner = signer.address;
    await deployVoting(owner)
    await deployNFT()
    // await setupRole()
    await mint(owner)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
