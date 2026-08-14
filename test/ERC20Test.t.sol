// SPDX-License-Identifier: Mit

pragma solidity ^0.8.30;

import {Test, console2} from "forge-std/Test.sol";

import {ERC20} from "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20 private erc20;

    address OWNER = makeAddr("OWNER");

    function setUp() external {
        vm.startPrank(OWNER);
        erc20 = new ERC20();
        vm.stopPrank();
    }
}
