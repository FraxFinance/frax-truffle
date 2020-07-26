var assert = require("assert");

var tether = artifacts.require("tether");
var frax = artifacts.require("FRAXStablecoin");
var fxs = artifacts.require("FRAXShares");
var frax_pool = artifacts.require("frax_pool");





contract('tether', function(accounts) {

  it("returns the tether balance of account[0]", function() {
    return tether.deployed().then(function(deployed) {
      deployed.balanceOf(accounts[0]).then(balanceOfOutput => console.log('tether balance of accounts[0]: ' + balanceOfOutput.words[0]));

      return deployed.balanceOf(accounts[0]).then(balanceOfOutput => balanceOfOutput.words[0]);
    });
  });

  it("approves 1000 tether to the frax_pool contract", function() {
    return tether.deployed().then(function(deployed) {
      return deployed.approve(frax_pool.address, 1000);
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

  it("sets the global collateral ratio to 0.5", function() {
    return frax.deployed().then(function(deployed) {
      return deployed.setGlobalCollateralRatio(500000);
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
  /* only use if setNewPool is a function in fxs.sol
  it("sets frax_pool as a pool address using setNewPool", function(){ 
    return fxs.deployed().then(function(deployed) {
      console.log('frax_pool address: ' + frax_pool.address);
      return deployed.setNewPool(frax_pool.address);
    });
  });
  */

});




//
contract('frax_pool', function(accounts) {
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

  it("sets the pool ceiling to 100,000 FRAX", function(){ 
    return frax_pool.deployed().then(function (deployed){
      return deployed.setPoolCeiling(100000);
    });
  });

  it("sets the price of the collateral (tether) to $1", function(){
    return frax_pool.deployed().then(function (deployed){
      return deployed.setPrice(1000000);
    });
  });

  it("mints 500 FRAX at 50% collateral ratio (from above), using mintFrax", function(){
    return frax_pool.deployed().then(function (deployed) {
      return deployed.mintFrax(500, 500);
    });
  });

});


contract('FRAXStablecoin', function(accounts) {
  it("has a balance of 500 FRAX", function(){ 
    return frax.deployed().then(function (deployed) {

      return assert(deployed.balanceOf(accounts[0]), 500, "account[0] balance is not 500 FRAX");;
    });
  });

});