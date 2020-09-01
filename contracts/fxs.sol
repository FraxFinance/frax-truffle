pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./frax.sol";
import "./SafeMath.sol";




contract FRAXShares is ERC20 {
    using SafeMath for uint256;
    string public symbol;
    uint8 public decimals = 18;
    address public FRAXStablecoinAdd;
    
    uint256 genesis_supply;
    uint256 public maximum_supply; //no FXS can be minted under any condition past this number
    uint256 public FXS_DAO_min; //minimum FXS required to join DAO groups 

    address owner_address;
    
    mapping(address => bool) public frax_pools; //same mapping and variable in FRAXStablecoin 
    
    address oracle_address;
    
    FRAXStablecoin FRAX;

    constructor(
    string memory _symbol, 
    uint256 _genesis_supply,
    uint256 _maximum_supply,
    address _oracle_address,
    address _owner_address)
    
    public 
    {
    symbol = _symbol;
    genesis_supply = _genesis_supply;
    maximum_supply = _maximum_supply; 
    owner_address = _owner_address;
    oracle_address = _oracle_address;
    
    _mint(owner_address, genesis_supply);


}

    function setOracle(address new_oracle) public onlyByOracle {
        oracle_address = new_oracle;
    }
    
    function setFRAXAddress(address frax_contract_address) public onlyByOracle {
        FRAX = FRAXStablecoin(frax_contract_address);
    }
    
    function setFXSMinDAO(uint256 min_FXS) public onlyByOracle {
        FXS_DAO_min = min_FXS;
    }

    function mint(address to, uint256 amount) public onlyPools {
        require(totalSupply() + amount < maximum_supply, "no more FXS can be minted, max supply reached");
        _mint(to, amount);
    }
    

    modifier onlyPools() {
       require(frax_pools[msg.sender] == true, "only frax pools can mint new FRAX");
        _;
    } 
    
    modifier onlyByOracle() {
        require(msg.sender == oracle_address, "you're not the oracle :p");
        _;
    }
    
    //this function is what other frax pools will call to mint new FXS (similar to the FRAX mint) 
    function pool_mint(address m_address, uint256 m_amount) public onlyPools {
        require(totalSupply() + m_amount < maximum_supply, "no more FXS can be minted, max supply reached");
        super._mint(m_address, m_amount);
    }
    
}
