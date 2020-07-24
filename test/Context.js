const tether = artifacts.require("tether");

contract("tether", accounts => {
  it("should deploy", async () => {
    tether.deployed()
  });
});
