var assert = require("assert");

var tether = artifacts.require("tether");
var frax = artifacts.require("FRAXStablecoin");
var fxs = artifacts.require("FRAXShares");
var frax_pool = artifacts.require("frax_pool");


contract('tether', function(accounts) {

  it("returns the tether balance of account[0]", function() {
    return tether.deployed().then(function(deployed) {
      console.log('tether balance of accounts[0]: ');
      deployed.balanceOf(accounts[0]).then(balanceOfOutput => console.log(balanceOfOutput.words[0]));

      return deployed.balanceOf(accounts[0]).then(balanceOfOutput => balanceOfOutput.words[0]);
    });
  });

});

contract('FRAXStablecoin', function(accounts) {
  it("returns the FRAX balance of account[0]", function() {
    return frax.deployed().then(function(deployed) {
      console.log('FRAX balance of accounts[0]: ');
      return deployed.balanceOf(accounts[0]).then(balanceOfOutput => console.log(balanceOfOutput.words[0])); //can also use balanceOfOutput.toNumber() (github.com/indutny/bn.js)
    });
  });

  it("sets frax_pool as a pool address using setNewPool", function(){
    return frax.deployed().then(function(deployed) {
      console.log('frax_pool address: ' + frax_pool.address);
      return deployed.setNewPool(frax_pool.address);
    });
  });

  it("sets the prices of FRAX to $1 and FXS to $2", function(){ 
    return frax.deployed().then(function(deployed){ 
      console.log("FRAX price: $1.000000, FXS price: $2.000000");
      return deployed.setPrices(1000000, 2000000);
    });
  });

});

contract('FRAXShares', function(accounts) {
  it("returns the FXS balance of account[0]", function() {
    return fxs.deployed().then(function(deployed) {
      console.log('FXS balance of account[0]: ');
      return deployed.balanceOf(accounts[0]).then(balanceOfOutput => console.log(balanceOfOutput.toNumber()));
    });
  });

});

contract('tether_pool', function(accounts) {
  it("sets the collateral address to the tether contract address", function(){
    return frax_pool.deployed().then(function (deployed){ 
      console.log('tether contract address: ' + tether.address);
      return deployed.setCollateralAdd(tether.address);
    });
  });

  it("sets the FRAX address to the FRAX contract address", function(){ 
    return frax_pool.deployed().then(function (deployed){
      console.log('FRAX contract address: ' + frax.address);
      return deployed.setFRAXAddress(frax.address);
    });
  });

});


