// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {IERC20} from "./IERC20.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InvalidSender(address sender);

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

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal virtual {
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);

        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }

            unchecked {
                _approve(owner, spender, currentAllowance - value);
            }
        }
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, value);
        _update(from, to, value);

        return true;
    }

    function _mint(address account, uint256 value) internal virtual {
        if (account == address(0)) revert ERC20InvalidReceiver(address(0));

        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal virtual {
        if (account == address(0)) revert ERC20InvalidSender(address(0));

        _update(account, address(0), value);
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

        emit Transfer(from, to, value);
    }
}
