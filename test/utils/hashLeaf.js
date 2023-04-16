const ethers = require('ethers');

const args = process.argv.slice(2);

if (args.length !== 2) {
    console.log(`please supply the correct parameters:
    address: the address of the whitelisted participants
    tier: the tier of the whitelisted participants
  `);
    process.exit(1);
}

async function main(address, tier) {
    const leaf = ethers.utils.solidityKeccak256(
        ['address', 'uint8'],
        [address, parseInt(tier)]
    );

    process.stdout.write(leaf);
}

// Pattern recommended to be able to use async/await everywhere
// and properly handle errors.
main(args[0], args[1])
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
