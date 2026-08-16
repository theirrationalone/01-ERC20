// SPDX-License-Identifier: Mit

pragma solidity ^0.8.30;

import {Test, console2} from "forge-std/Test.sol";
import {ERC20} from "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20 private token;

    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");

    function setUp() external {
        vm.startPrank(owner);
        token = new ERC20();
        vm.stopPrank();
    }

    function test_initialState() public view {
        uint256 totalSupply = token.totalSupply();
        uint256 tokenBalance = token.balanceOf(address(token));
        uint256 ownerBalance = token.balanceOf(owner);
        uint256 aliceBalance = token.balanceOf(alice);
        uint256 bobBalance = token.balanceOf(bob);
        uint256 charlieBalance = token.balanceOf(charlie);

        console2.log("Token total supply   : ", totalSupply);
        console2.log("Token balance        : ", tokenBalance);
        console2.log("Token owner balance  : ", ownerBalance);
        console2.log("Token alice balance  : ", aliceBalance);
        console2.log("Token bob balance    : ", bobBalance);
        console2.log("Token charlie balance: ", charlieBalance);

        assertEq(totalSupply, 0);
        assertEq(tokenBalance, 0);
        assertEq(ownerBalance, 0);
        assertEq(aliceBalance, 0);
        assertEq(bobBalance, 0);
        assertEq(charlieBalance, 0);
        assertEq(totalSupply, tokenBalance + ownerBalance + aliceBalance + bobBalance + charlieBalance);
    }
}
