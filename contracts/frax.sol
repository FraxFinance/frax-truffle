pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./fxs.sol";
import "./frax_pool.sol";




contract FRAXStablecoin is ERC20 {
    using SafeMath for uint256;
    string public symbol;
    uint8 public decimals = 18;
    address[] public owners;

    //the addresses in this array are added by the oracle and these contracts are able to mint frax
    address[] frax_pools_array;

    //mapping is also used for faster verification
    mapping(address => bool) public frax_pools; 
    
    mapping(address => uint256) public pool_prices;
    
    //add other future monetary policy contracts to this
    mapping(address => bool) public frax_monetary_policy_contracts;

    uint256 public FRAX_price; //6 decimals of precision
    uint256 public FXS_price; //6 decimals of precision
    uint256 public global_collateral_ratio; //6 decimals of precision, e.g. 924102 = 0.924102
    address oracle_address; 
    uint256 public redemption_fee; //6 decimals of precision, divide by 1000000 in calculations for fee
    uint256 public minting_fee; //6 decimals of precision, divide by 1000000 in calculations for fee

    modifier onlyMonPol() {
       require(frax_monetary_policy_contracts[msg.sender] == true, "only frax monetary policy contracts can use this!");
        _;
    } 
     
    modifier onlyPools() {
       require(frax_pools[msg.sender] == true, "only frax pools can mint new FRAX");
        _;
    } 
    
    
    modifier onlyByOracle() {
        require(msg.sender == oracle_address, "you're not the oracle :p");
        _;
    }
    
    constructor(
    string memory _symbol, 
    address _oracle_address) 
    public 
    {
    symbol = _symbol;
    oracle_address = _oracle_address;
}

    //public implementation of internal _mint()
    function mint(uint256 amount) public virtual onlyByOracle {
        _mint(msg.sender, amount);
    }

    //used by pools when user redeems
    function poolBurn(uint256 amount) public onlyPools {
        _burn(tx.origin,amount);
    }

    //this function is what other frax pools will call to mint new FRAX 
    function pool_mint(address m_address, uint256 m_amount) public onlyPools {
        super._mint(m_address, m_amount);
    }

    //adds collateral addresses supported, such as tether and busd, must be ERC20 
    function setNewPool(address pool_address) public onlyByOracle {
        frax_pools[pool_address] = true; 
        frax_pools_array.push(pool_address);
    }



    //adds the monetary policy contracts, hop, backstep etc 
    function setMonetaryPolicyContract(address con_address) public onlyByOracle {
        frax_monetary_policy_contracts[con_address] = true; 
    }


    //When an oracle contract is deployed in the future,  
    // the updated price must be within 10% of the old price as reported by the contract, this is to prevent accidental mispricings, a change of greater than 10% requires multiple transactions
    //this logic is done by the offchain oracle in v1 for simplicity

    function setPrices(uint256 FRAX_p,uint256 FXS_p) public onlyByOracle {
        FRAX_price = FRAX_p;
        FXS_price = FXS_p;
    }
    

    //iterate through all frax pools and calculate all value of collateral in all pools globally 
    function globalCollateralValue() public view returns (uint256) {
        uint256 pool_value;
        uint256 total_collateral_value; 
        
        for (uint i=0; i<frax_pools_array.length; i++){
            ERC20 pool_token = ERC20(frax_pools_array[i]);
            pool_value = pool_token.balanceOf(frax_pools_array[i]) * frax_pool(frax_pools_array[i]).collateral_price_int();
            total_collateral_value = total_collateral_value + pool_value;
   
    }
    return total_collateral_value;
}
    
    //there needs to be a time interval that this can be called. Otherwise it can be called multiple times per expansion.
    uint256 last_call_time; //last time the setNewCollateralRatio function was called
    function setNewCollateralRatio() public {
        require(block.timestamp - last_call_time >= 3600 && FRAX_price != 1000000);  //3600 seconds means can be called once per hour, 86400 seconds is per day, callable only if FRAX price is not $1
        
        uint256 tot_collat_value =  globalCollateralValue();
        uint256 globalC_ratio = totalSupply().div(tot_collat_value); //div by 12 places, FRAX has 18 precision and c_ratio has 6              
        
        //step increments are .5% 
        if (FRAX_price > 1000000) {
            global_collateral_ratio = globalC_ratio - 5000;
        }    
        else {
            global_collateral_ratio = globalC_ratio + 5000;
        }
    last_call_time = block.timestamp; //set the time of the last expansion
            
    }
        

    

    
    function setGlobalCollateralRatio(uint256 coll_ra) public onlyByOracle {
        require(coll_ra < 1000001, "collateral ratio must have 6 decimals of precision and never go above 1.0000000");
        global_collateral_ratio = coll_ra;
    }

    function setOracle(address new_oracle) public onlyByOracle {
        oracle_address = new_oracle;
    }

    function setRedemptionFee(uint256 red_fee) public onlyByOracle {
        redemption_fee = red_fee;
    }

     function setMintingFee(uint256 min_fee) public onlyByOracle {
        minting_fee = min_fee;
    }  
    
    

    


    
}
