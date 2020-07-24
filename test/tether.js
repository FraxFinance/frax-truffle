const tether = artifacts.require("tether");

contract("tether", accounts => {
  it("should need arguments before this runs", () =>
    tether.deployed()
      .then(instance => instance.getBalance.call(accounts[0]))
      .then(balance => {
        assert.equal(
          balance.valueOf(),
          10000,
          "10000 wasn't in the first account"
        );
      }));
});