// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {IERC20} from "./IERC20.sol";

contract ERC20 is IERC20 {
    error ERC20InsufficientBalance(address from, uint256 fromBalance, uint256 value);

    mapping(address account => uint256 balance) private _balances;
    mapping(address owner => mapping(address spender => uint256 allowance)) private _allowances;
    uint256 private _totalSupply;

    function transfer(address to, uint256 value) public virtual override returns (bool) {
        _update(msg.sender, to, value);
        return true;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];

            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }

            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }
    }
}
