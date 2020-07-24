# frax-truffle
truffle environment for frax solidity smart contract testing


## initializing dev environment (assumming you don't already have truffle & ganache)
1. required dependencies: node, npm

2. install truffle: `$npm install -g truffle`

3. install ganache: https://www.trufflesuite.com/docs/ganache/quickstart

## testing the contracts

1. compile contracts
   - compiling contracts in ./contracts: `$truffle compile`
    
2. deploy contracts onto local instance of Ethereum (Ganache)
   - to run 2_deploy_contracts.js in frax-truffle/migrations:
     - `$truffle migrate`
     - `$truffle migrate --reset //this re-deploys the contracts if they're already deployed`

3. run test scripts
   - to run all of the test scripts in ./test:
     - `$truffle test`
   - to run a specific test script:
     -`$truffle test ./specific-test-script.js`
  
  
## config
truffle uses the version of the solidity compiler as specified in ./truffle-config.js (currently set to 0.6.6).

truffle will deploy to the port specified in ./truffle-config.js (currently set to port 7545, which is also default for Ganache). if you
set a different port in ganache, make sure to update this config file.
  
## resources
info on migrations: https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations

info on how to write test scripts (in javascript): https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
