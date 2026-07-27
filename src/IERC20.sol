// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

/*
 @author: theirrationalone
 @dev: Simplest, Core ERC20 Interface (The Design) IERC20
 @status: Finished!
*/

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalsupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
