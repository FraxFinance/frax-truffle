const path = require("path");
var HDWalletProvider = require('truffle-hdwallet-provider');
var infuraApiKey = 'v3/0a5b1633380b415d9b7342823baad798'
var mnemonic = "now that ice cream choose shuffle sand sport end stuff tone word";

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8546,
      network_id: '5777'
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/' + infuraApiKey);
      },
      network_id: 3,
      gas: 4612388
    }
  },
  compilers: {
  	solc: {
  		version: '0.6.6'
  	}
  }
};
