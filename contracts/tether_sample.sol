pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */

contract tether is ERC20 {
    using SafeMath for uint256;
    string public symbol;
    uint8 public decimals = 18;
    address public FRAXStablecoinAdd;
//    address[] public owners;
    uint256 genesis_supply;
//    uint256 ownerCount; //number of different addresses that hold FXS
//    mapping(address => uint256) public balances;
//    mapping(address => mapping (address => uint256)) allowed;
    address owner_address;

    constructor(
    string memory _symbol, 
    uint256 _genesis_supply,
    address _owner_address) 
    public 
    {
    symbol = _symbol;
    genesis_supply = _genesis_supply;
    owner_address = _owner_address;

    _mint(owner_address, genesis_supply);


}

function mint(address to, uint256 amount) public {
        require(msg.sender == FRAXStablecoinAdd);
        _mint(to, amount);
    }

    
}