// SPDX-License-Identifier: Mit

pragma solidity ^0.8.30;

import {Test, console2} from "forge-std/Test.sol";
import {ERC20} from "../src/ERC20.sol";
import {IERC20} from "../src/IERC20.sol";

contract ERC20Test is Test {
    ERC20Harness private token;

    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");

    function setUp() external {
        vm.startPrank(owner);
        token = new ERC20Harness();
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

    function test_mint() public {
        uint256 amount = 100;

        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(address(0), alice, amount);
        token.exposedMint(alice, amount);
        vm.stopPrank();

        uint256 aliceBalance = token.balanceOf(alice);
        uint256 totalSupply = token.totalSupply();

        console2.log("Token alice balance: ", aliceBalance);
        console2.log("Token total supply : ", totalSupply);

        assertEq(aliceBalance, amount);
        assertEq(totalSupply, amount);
    }

    function test_mintMultipleTimes() public {
        uint256 amount = 100;

        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(address(0), alice, amount);
        token.exposedMint(alice, amount);

        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(address(0), alice, amount - 50);
        token.exposedMint(alice, amount - 50);
        vm.stopPrank();

        uint256 aliceBalance = token.balanceOf(alice);
        uint256 totalSupply = token.totalSupply();

        console2.log("Token alice balance: ", aliceBalance);
        console2.log("Token total supply : ", totalSupply);

        assertEq(aliceBalance, amount + 50);
        assertEq(totalSupply, amount + 50);
    }

    function test_mintToDifferentAccounts() public {
        uint256 amount = 100;

        vm.startPrank(owner);
        token.exposedMint(alice, amount);
        token.exposedMint(bob, amount - 50);
        vm.stopPrank();

        uint256 aliceBalance = token.balanceOf(alice);
        uint256 bobBalance = token.balanceOf(bob);
        uint256 totalSupply = token.totalSupply();

        console2.log("Token alice balance: ", aliceBalance);
        console2.log("Token bob balance  : ", bobBalance);
        console2.log("Token total supply : ", totalSupply);

        assertEq(aliceBalance, amount);
        assertEq(bobBalance, amount - 50);
        assertEq(totalSupply, amount + (amount - 50));
        assertEq(totalSupply, aliceBalance + bobBalance);
    }
}

contract ERC20Harness is ERC20 {
    function exposedMint(address account, uint256 value) external {
        _mint(account, value);
    }

    function exposedBurn(address account, uint256 value) external {
        _burn(account, value);
    }
}
