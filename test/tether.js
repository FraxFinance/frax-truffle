var assert = require("assert");

var tether = artifacts.require("tether");
var frax = artifacts.require("FRAXStablecoin");


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
      return deployed.balanceOf(accounts[0]).then(balanceOfOutput => console.log(balanceOfOutput.words[0]));
    });
  });

});
