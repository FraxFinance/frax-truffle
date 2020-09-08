pragma solidity ^0.6.0;

import "./SafeMath.sol";
import "./fxs.sol";
import "./frax.sol";



contract frax_pool {
    using SafeMath for uint256;
    ERC20 collateral_token;
    address pool_oracle;
    FRAXShares FXS;
    FRAXStablecoin FRAX;
    uint256 public collateral_price_int; //6 decimals of precision, e.g. 1023000 represents $1.023
    
    //pool_ceiling is the total units of collateral that a pool contract can hold
    uint256 pool_ceiling;
    
        constructor(
     address _oracle_address) 
    public 
    {

    pool_oracle = _oracle_address;
}

    modifier onlyByOracle() {
        require(msg.sender == pool_oracle, "you're not the oracle :p");
        _;
    }
 

    
    function setPoolCeiling(uint256 new_ceiling) public onlyByOracle {
        pool_ceiling = new_ceiling;
    }

    function setOracle(address new_oracle) public onlyByOracle {
        pool_oracle = new_oracle;
    }
    
    function setCollateralAdd(address collateral_address) public onlyByOracle {
        collateral_token = ERC20(collateral_address);
    }
    
    function setFRAXAddress(address frax_contract_address) public onlyByOracle {
        FRAX = FRAXStablecoin(frax_contract_address);
    }
    
    function setFXSAddress(address fxs_contract_address) public onlyByOracle {
        FXS = FRAXShares(fxs_contract_address);
    }
    
    function setPrice(uint256 c_price) public onlyByOracle {
        collateral_price_int = c_price;
    }
    
    //we separate out the 1t1, fractional and algorithmic minting functions for gas effeciency 
    function mint1t1FRAX(uint256 collateral_amount) public {
        require(FRAX.global_collateral_ratio() == 1000000, "FRAX isn't 100% collateralized");
        require((collateral_token.balanceOf(address(this))) + collateral_amount < pool_ceiling, "pool ceiling reached, no more FRAX can be minted with this collateral");
        
        uint256 col_price = collateral_price_int;
        uint256 mint_fee = FRAX.minting_fee(); 
        collateral_amount = (collateral_amount * mint_fee).div(100);
        uint256 c_amount = ((collateral_amount * col_price) * mint_fee).div(100); //replace with safemath .div()
        collateral_token.transferFrom(msg.sender, address(this), collateral_amount);
        FRAX.pool_mint(msg.sender, c_amount);
        
    }

    function mintAlgorithmicFRAX(uint256 fxs_amount) public {
        require(FRAX.global_collateral_ratio() == 0, "FRAX isn't 100% algorithmic");
        
        uint256 mint_fee = FRAX.minting_fee(); 
        uint256 fxs_price = FRAX.FXS_price();
        uint256 f_amount = (fxs_amount * fxs_price);
        FXS.burnFrom(msg.sender, fxs_amount);
        FRAX.pool_mint(msg.sender, f_amount);
    }


//will fail if fully collateralized or algorithmic
    function mintFractionalFRAX(uint256 collateral_amount, uint256 FXS_amount) public {
        require((collateral_token.balanceOf(address(this))) + collateral_amount < pool_ceiling, "pool ceiling reached, no more FRAX can be minted with this collateral");
        //since solidity truncates division, every divsion operation must be the last operation in the equation to ensure minimum error
        //the contract must check the proper ratio was sent to mint FRAX. We do this by seeing the minimum mintable FRAX based on each amount 
        uint256 fxs_needed;
        uint256 collateral_needed;
        uint256 mint_fee = FRAX.minting_fee(); 
        uint256 fxs_price = FRAX.FXS_price();
        uint256 col_ratio = FRAX.global_collateral_ratio();
        uint256 col_price = collateral_price_int;
        
        uint256 c_amount = (collateral_amount * col_price) / col_ratio; //replace with safemath .div()
        uint256 f_amount = (FXS_amount * fxs_price) / (1e6 - col_ratio); //fxs_price has 6 extra precision, col_ratio also has 6 extra precision; replace with safemath .div()
        
        
        if (c_amount < f_amount) {
            collateral_token.transferFrom(msg.sender, address(this), collateral_amount);
            fxs_needed = (c_amount * (1e6 - col_ratio)) / 1e6;
            FRAX.pool_mint(msg.sender, collateral_amount);
            FXS.burnFrom(msg.sender, fxs_needed);
        }
        
        else {
            collateral_needed = (f_amount * col_ratio) / 1e6;
            collateral_token.transferFrom(msg.sender, address(this), collateral_needed);
            FRAX.pool_mint(msg.sender, f_amount); 
            FXS.burnFrom(msg.sender, FXS_amount);
        }
    }

    function redeem1t1FRAX(uint256 FRAX_amount) public {
        require(FRAX.global_collateral_ratio() == 1000000, "FRAX isn't 100% collateralized");
        uint256 red_fee = FRAX.redemption_fee(); 
        collateral_token.transferFrom(address(this), msg.sender, ((FRAX_amount * FRAX.FRAX_price()) / 1e6)); 
        FRAX.burnFrom(msg.sender, FRAX_amount);
    }

//will fail if fully collateralized or algorithmic
    function redeemFractionalFRAX(uint256 FRAX_amount) public {
        uint256 red_fee = FRAX.redemption_fee(); 
        uint256 col_ratio = FRAX.global_collateral_ratio();
        collateral_token.transferFrom(address(this), msg.sender, (FRAX_amount * (1e6 - col_ratio)) / 1e6); 
        FXS.pool_mint(tx.origin, (FRAX_amount * (1e6 - col_ratio)) / 1e6);
        FRAX.burnFrom(msg.sender, FRAX_amount);
    }

    function redeemAlgorithmicFRAX(uint256 FRAX_amount) public {
        require(FRAX.global_collateral_ratio() == 0, "FRAX isn't 100% algorithmic");     
        uint256 red_fee = FRAX.redemption_fee(); 
        uint256 col_ratio = FRAX.global_collateral_ratio();
        FXS.pool_mint(tx.origin, ((FRAX_amount * FRAX.FRAX_price()) / 1e6));
        FRAX.burnFrom(msg.sender, FRAX_amount);
    }

    //Function can be called by an FXS holder to have the protocol buy back FXS with excess collateral value from a desired collateral pool
    function buyBackFXS(uint256 FXS_amount, uint256 collateral_amount) public {
        uint256 tot_collat_value =  FRAX.globalCollateralValue();
        //calculate how much FRAX actually needs to be backed by collateral at current collat ratio 
        uint256 backed_FRAX_value = FRAX.totalSupply() * FRAX.global_collateral_ratio().div(1e6);
        uint256 fxs_value = FXS_amount * FRAX.FXS_price();
        uint256 possible_buyBack_value = tot_collat_value - backed_FRAX_value;
    //if the total collateral value is higher than the amount required at the current collateral ratio then buy back up to the possible FXS with the desired collateral
    if (tot_collat_value > backed_FRAX_value && possible_buyBack_value > fxs_value) {
        collateral_token.transferFrom(address(this), msg.sender, (possible_buyBack_value - fxs_value));
        FXS.burnFrom(msg.sender, FXS_amount);
        
    }
        
    }


}
