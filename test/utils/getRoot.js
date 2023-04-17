const ethers = require('ethers');
const { MerkleTree } = require('merkletreejs');

const args = process.argv.slice(2);

// if (args.length !== 1) {
//     console.log(`please supply the correct parameters:
//     leaves: the leaves of the merkle tree
//   `);
//     process.exit(1);
// }

const coder = ethers.utils.defaultAbiCoder;

async function main(leaves) {
    const array = ethers.utils.arrayify(leaves);

    const decodedLeaves = coder.decode(['bytes32[]'], array);

    // console.log('decodedLeaves', decodedLeaves[0]);

    const tree = new MerkleTree(decodedLeaves[0], ethers.utils.keccak256, {
        sortPairs: true,
    });
    const root = tree.getHexRoot();

    // console.log('root', root);

    process.stdout.write(root);
}

// Pattern recommended to be able to use async/await everywhere
// and properly handle errors.
main(args[0], args[1])
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
