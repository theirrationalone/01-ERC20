// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {IERC20} from "./IERC20.sol";

contract ERC20 is IERC20 {
    mapping(address account => uint256 balance) private _balances;
}
