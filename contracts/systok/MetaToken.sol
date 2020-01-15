pragma solidity ^0.5.12;

import { ERC20Burnable } from "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import { ERC20Detailed } from "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import { ERC20 } from "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

/**
 * @dev Consolidation of OpenZeppelin's 'Roles' and 'MinterRole' into one
 */
contract MinterRole {
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    mapping (address => bool) private _minters;

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return _minters[account];
    }

    function _addMinter(address account) internal {
        if(!isMinter(account)){
            _minters[account] = true;
            emit MinterAdded(account);
        }
    }

    function _removeMinter(address account) internal {
        if(isMinter(account)){
            _minters[account] = false;
            emit MinterRemoved(account);
        }
    }
}


/**
 * @dev Extension of `ERC20` that adds a set of accounts with the `MinterRole`,
 * which have permission to mint (create) new tokens as they see fit.
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev See `ERC20._mint`.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

/**
 * @title MetaToken (MTA)
 * @dev MTA is used throughout the mStable Standard; namely through governance,
 *      forging and re-collateralisation
 */
contract MetaToken is ERC20Burnable, ERC20Detailed, ERC20Mintable {

    /**
      * @dev Initialises basic ERC20 token and mints core supply
      */
    constructor (
        address _initialRecipient
    )
        public
        ERC20Detailed(
            "mStable Meta",
            "MTA",
            18
        )
    {
        uint initialSupply = 100000000 * (10 ** 18);
        _mint(_initialRecipient, initialSupply);
    }
}
