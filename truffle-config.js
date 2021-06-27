const fs = require('fs');

const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonic = fs.readFileSync(".mnemonic").toString().trim();

module.exports = {
  networks: {
    testnet: {
      provider: () => new HDWalletProvider(mnemonic, 'https://http-testnet.hecochain.com'),
      network_id: 256,
      // from: '0xa9bB710996d6ed61B83a5EAB583bAe683199c2de',        // Account to send txs from (default: accounts[0])
      // gas: 550000,        // Ropsten has a lower block limit than mainnet
      // gasPrice: 20000000000,  // 20 gwei (in wei) (default: 100 gwei)
      // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    mainnet: {
      provider: () => new HDWalletProvider(mnemonic, 'https://http-mainnet.hecochain.com'),
      network_id: 128,
      // from: '0xa9bB710996d6ed61B83a5EAB583bAe683199c2de',        // Account to send txs from (default: accounts[0])
      // gas: 5500000,        // Ropsten has a lower block limit than mainnet
      // gasPrice: 20000000000,  // 20 gwei (in wei) (default: 100 gwei)
      // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      // version: "0.5.1",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    },
  }
};
