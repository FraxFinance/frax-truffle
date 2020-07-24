//need to use names of contracts, not filenames
var Context = artifacts.require("Context");
var SafeMath = artifacts.require("SafeMath");
var IERC20 = artifacts.require("ERC20");
var tether_sample = artifacts.require("tether");
var frax = artifacts.require("FRAXStablecoin");
var fxs = artifacts.require("FRAXShares");
var frax_pool = artifacts.require("frax_pool");

module.exports = function(deployer, network, accounts) {
	deployer.deploy(tether_sample, "USDT", 10000, accounts[0]);
	deployer.deploy(frax, "FRAX", accounts[0]).then(
		function() {
			return deployer.deploy(fxs, "FXS", 10000, accounts[0], accounts[0], frax.address);
		}
	);
	deployer.deploy(frax_pool, accounts[0]);
};
