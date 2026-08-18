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

    function test_mintZero() public {
        vm.startPrank(owner);
        token.exposedMint(alice, 0);
        vm.stopPrank();

        uint256 aliceBalance = token.balanceOf(alice);
        uint256 totalSupply = token.totalSupply();

        console2.log("Token alice balance: ", aliceBalance);
        console2.log("Token total supply : ", totalSupply);

        assertEq(aliceBalance, 0);
        assertEq(totalSupply, 0);
    }

    function test_revertWhen_mintToZeroAddress() public {
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 charlieBalanceBefore = token.balanceOf(charlie);

        vm.startPrank(owner);
        vm.expectRevert(abi.encodeWithSelector(ERC20.ERC20InvalidReceiver.selector, address(0)));
        token.exposedMint(address(0), 100);
        vm.stopPrank();

        uint256 totalSupplyAfter = token.totalSupply();
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 charlieBalanceAfter = token.balanceOf(charlie);

        console2.log("Token total supply before   : ", totalSupplyBefore);
        console2.log("Token alice balance before  : ", aliceBalanceBefore);
        console2.log("Token bob balance before    : ", bobBalanceBefore);
        console2.log("Token charlie balance before: ", charlieBalanceBefore);

        console2.log("--------------");

        console2.log("Token total supply after   : ", totalSupplyAfter);
        console2.log("Token alice balance after  : ", aliceBalanceAfter);
        console2.log("Token bob balance after    : ", bobBalanceAfter);
        console2.log("Token charlie balance after: ", charlieBalanceAfter);

        assertEq(totalSupplyAfter, totalSupplyBefore);
        assertEq(aliceBalanceAfter, aliceBalanceBefore);
        assertEq(bobBalanceAfter, bobBalanceBefore);
        assertEq(charlieBalanceAfter, charlieBalanceBefore);
    }

    function test_mintMaxUint() public {
        uint256 maxAmount = type(uint256).max;

        uint256 totalSupplyBefore = token.totalSupply();
        uint256 aliceBalanceBefore = token.balanceOf(alice);

        vm.startPrank(owner);
        token.exposedMint(alice, maxAmount);
        vm.stopPrank();

        uint256 totalSupplyAfter = token.totalSupply();
        uint256 aliceBalanceAfter = token.balanceOf(alice);

        console2.log("Token total supply before : ", totalSupplyBefore);
        console2.log("Token alice balance before: ", aliceBalanceBefore);
        console2.log("Token total supply after  : ", totalSupplyAfter);
        console2.log("Token alice balance after : ", aliceBalanceAfter);

        assertEq(totalSupplyBefore, 0);
        assertEq(aliceBalanceBefore, 0);
        assertEq(totalSupplyAfter, maxAmount);
        assertEq(aliceBalanceAfter, maxAmount);
    }

    function test_mintMoreThanMaxUint() public {
        uint256 maxAmount = type(uint256).max;

        uint256 totalSupplyBefore = token.totalSupply();
        uint256 aliceBalanceBefore = token.balanceOf(alice);

        vm.startPrank(owner);
        token.exposedMint(alice, maxAmount);
        vm.expectRevert();
        token.exposedMint(alice, 1);
        vm.stopPrank();

        uint256 totalSupplyAfter = token.totalSupply();
        uint256 aliceBalanceAfter = token.balanceOf(alice);

        console2.log("Token total supply before : ", totalSupplyBefore);
        console2.log("Token alice balance before: ", aliceBalanceBefore);
        console2.log("Token total supply after  : ", totalSupplyAfter);
        console2.log("Token alice balance after : ", aliceBalanceAfter);

        assertEq(totalSupplyBefore, 0);
        assertEq(aliceBalanceBefore, 0);
        assertEq(totalSupplyAfter, maxAmount);
        assertEq(aliceBalanceAfter, maxAmount);
    }

    modifier _mintUsers() {
        uint256 amount = 1000;
        vm.startPrank(owner);
        token.exposedMint(alice, amount);
        token.exposedMint(bob, amount);
        token.exposedMint(charlie, amount);
        vm.stopPrank();
        _;
    }

    function test_transferSimple() public _mintUsers {
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 usersTotalBalanceBefore = aliceBalanceBefore + bobBalanceBefore + token.balanceOf(charlie);
        uint256 totalSupplyBefore = token.totalSupply();

        assertEq(totalSupplyBefore, usersTotalBalanceBefore);

        uint256 transferAmount = 100;

        vm.startPrank(alice);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(alice, bob, transferAmount);
        bool success = token.transfer(bob, transferAmount);
        assert(success);
        vm.stopPrank();

        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 usersTotalBalanceAfter = aliceBalanceAfter + bobBalanceAfter + token.balanceOf(charlie);
        uint256 totalSupplyAfter = token.totalSupply();

        assertEq(aliceBalanceAfter, aliceBalanceBefore - transferAmount);
        assertEq(bobBalanceAfter, bobBalanceBefore + transferAmount);
        assertEq(usersTotalBalanceAfter, usersTotalBalanceBefore);
        assertEq(totalSupplyAfter, totalSupplyBefore);
    }

    function test_revertsWhen_transfer_exceedsBalance() public _mintUsers {
        uint256 transferAmount = 1001;

        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 usersTotalBalanceBefore = aliceBalanceBefore + bobBalanceBefore + token.balanceOf(charlie);

        vm.startPrank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(ERC20.ERC20InsufficientBalance.selector, alice, aliceBalanceBefore, transferAmount)
        );
        bool success = token.transfer(bob, transferAmount);
        assert(!success);
        vm.stopPrank();

        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 usersTotalBalanceAfter = aliceBalanceAfter + bobBalanceAfter + token.balanceOf(charlie);

        assertEq(aliceBalanceAfter, aliceBalanceBefore);
        assertEq(bobBalanceAfter, bobBalanceBefore);
        assertEq(usersTotalBalanceAfter, usersTotalBalanceBefore);
        assertEq(totalSupplyAfter, totalSupplyBefore);
    }

    function test_transfer_zeroAmount() public _mintUsers {
        uint256 transferAmount = 0;

        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 usersTotalBalanceBefore = aliceBalanceBefore + bobBalanceBefore + token.balanceOf(charlie);

        vm.startPrank(alice);
        bool success = token.transfer(bob, transferAmount);
        assert(success);
        vm.stopPrank();

        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 usersTotalBalanceAfter = aliceBalanceAfter + bobBalanceAfter + token.balanceOf(charlie);

        assertEq(aliceBalanceAfter, aliceBalanceBefore);
        assertEq(bobBalanceAfter, bobBalanceBefore);
        assertEq(usersTotalBalanceAfter, usersTotalBalanceBefore);
        assertEq(totalSupplyAfter, totalSupplyBefore);
    }

    function test_selfTransfer() public _mintUsers {
        uint256 transferAmount = 100;

        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 usersTotalBalanceBefore = aliceBalanceBefore + bobBalanceBefore + token.balanceOf(charlie);

        vm.startPrank(alice);
        bool success = token.transfer(alice, transferAmount);
        assert(success);
        vm.stopPrank();

        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 usersTotalBalanceAfter = aliceBalanceAfter + bobBalanceAfter + token.balanceOf(charlie);

        assertEq(aliceBalanceAfter, aliceBalanceBefore);
        assertEq(bobBalanceAfter, bobBalanceBefore);
        assertEq(usersTotalBalanceAfter, usersTotalBalanceBefore);
        assertEq(totalSupplyAfter, totalSupplyBefore);
    }

    function test_transferTo_zeroAddress() public _mintUsers {
        uint256 transferAmount = 100;

        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 usersTotalBalanceBefore = aliceBalanceBefore + bobBalanceBefore + token.balanceOf(charlie);

        vm.startPrank(alice);
        // vm.expectRevert(abi.encodeWithSelector(ERC20.ERC20InvalidReceiver.selector), address(0));
        bool success = token.transfer(address(0), transferAmount);
        assert(success);
        vm.stopPrank();

        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 usersTotalBalanceAfter = aliceBalanceAfter + bobBalanceAfter + token.balanceOf(charlie);

        assertEq(aliceBalanceAfter, aliceBalanceBefore);
        assertEq(bobBalanceAfter, bobBalanceBefore);
        assertEq(usersTotalBalanceAfter, usersTotalBalanceBefore);
        assertEq(totalSupplyAfter, totalSupplyBefore);
    }

    function test_approve() public _mintUsers {
        uint256 aliceAllowanceToBobBefore = token.allowance(alice, bob);
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 totalSupplyBefore = token.totalSupply();

        uint256 aliceApproveAmount = 100;

        vm.startPrank(alice);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Approval(alice, bob, aliceApproveAmount);
        bool success = token.approve(bob, aliceApproveAmount);
        assert(success);
        vm.stopPrank();

        uint256 aliceAllowanceToBobAfter = token.allowance(alice, bob);
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 totalSupplyAfter = token.totalSupply();

        assertEq(aliceBalanceAfter, aliceBalanceBefore);
        assertEq(bobBalanceAfter, bobBalanceBefore);
        assertEq(totalSupplyAfter, totalSupplyBefore);
        assertEq(aliceAllowanceToBobBefore, 0);
        assertEq(aliceAllowanceToBobAfter, aliceApproveAmount);
    }

    function test_approveReplacesExistingAllowance() public _mintUsers {
        uint256 aliceAllowanceToBobBefore = token.allowance(alice, bob);
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 totalSupplyBefore = token.totalSupply();

        uint256 aliceApproveAmount = 100;
        uint256 aliceNewApproveAmount = 50;

        vm.startPrank(alice);
        bool success = token.approve(bob, aliceApproveAmount);
        assert(success);
        assertEq(token.allowance(alice, bob), aliceApproveAmount);

        bool success2 = token.approve(bob, aliceNewApproveAmount);
        assert(success2);
        vm.stopPrank();

        uint256 aliceAllowanceToBobAfter = token.allowance(alice, bob);
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 totalSupplyAfter = token.totalSupply();

        assertEq(aliceBalanceAfter, aliceBalanceBefore);
        assertEq(bobBalanceAfter, bobBalanceBefore);
        assertEq(totalSupplyAfter, totalSupplyBefore);
        assertEq(aliceAllowanceToBobBefore, 0);
        assertEq(aliceAllowanceToBobAfter, aliceNewApproveAmount);
    }

    function test_approveResetAllowance() public _mintUsers {
        uint256 aliceAllowanceToBobBefore = token.allowance(alice, bob);
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 totalSupplyBefore = token.totalSupply();

        uint256 aliceApproveAmount = 100;
        uint256 aliceResetAllowance = 0;

        vm.startPrank(alice);
        bool success = token.approve(bob, aliceApproveAmount);
        assert(success);
        assertEq(token.allowance(alice, bob), aliceApproveAmount);

        bool success2 = token.approve(bob, aliceResetAllowance);
        assert(success2);
        vm.stopPrank();

        uint256 aliceAllowanceToBobAfter = token.allowance(alice, bob);
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 totalSupplyAfter = token.totalSupply();

        assertEq(aliceBalanceAfter, aliceBalanceBefore);
        assertEq(bobBalanceAfter, bobBalanceBefore);
        assertEq(totalSupplyAfter, totalSupplyBefore);
        assertEq(aliceAllowanceToBobBefore, 0);
        assertEq(aliceAllowanceToBobAfter, aliceResetAllowance);
    }

    function test_transferFrom() public _mintUsers {
        uint256 aliceAllowanceToBobBefore = token.allowance(alice, bob);
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 charlieBalanceBefore = token.balanceOf(charlie);
        uint256 totalSupplyBefore = token.totalSupply();

        uint256 aliceApproveAmount = 100;

        vm.startPrank(alice);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Approval(alice, bob, aliceApproveAmount);
        bool success = token.approve(bob, aliceApproveAmount);
        assert(success);
        vm.stopPrank();

        uint256 aliceAllowanceToBobAfter = token.allowance(alice, bob);
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 charlieBalanceAfter = token.balanceOf(charlie);
        uint256 totalSupplyAfter = token.totalSupply();

        assertEq(aliceBalanceAfter, aliceBalanceBefore);
        assertEq(bobBalanceAfter, bobBalanceBefore);
        assertEq(charlieBalanceAfter, charlieBalanceBefore);
        assertEq(totalSupplyAfter, totalSupplyBefore);
        assertEq(aliceAllowanceToBobBefore, 0);
        assertEq(aliceAllowanceToBobAfter, aliceApproveAmount);

        vm.startPrank(bob);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(alice, charlie, aliceApproveAmount);
        bool transferSuccess = token.transferFrom(alice, charlie, aliceApproveAmount);
        assert(transferSuccess);
        vm.stopPrank();

        uint256 aliceAllowanceToBobAfterTransfer = token.allowance(alice, bob);
        uint256 aliceBalanceAfterTransfer = token.balanceOf(alice);
        uint256 bobBalanceAfterTransfer = token.balanceOf(bob);
        uint256 charlieBalanceAfterTransfer = token.balanceOf(charlie);
        uint256 totalSupplyAfterTransfer = token.totalSupply();

        assertEq(aliceAllowanceToBobAfterTransfer, 0);
        assertEq(aliceBalanceAfterTransfer, aliceBalanceAfter - aliceApproveAmount);
        assertEq(bobBalanceAfterTransfer, bobBalanceAfter);
        assertEq(charlieBalanceAfterTransfer, charlieBalanceAfter + aliceApproveAmount);
        assertEq(totalSupplyAfterTransfer, totalSupplyAfter);
    }

    function test_transferFrom_revertsOnTransfer_moreThanAllowed() public _mintUsers {
        uint256 aliceApproveAmount = 100;

        vm.startPrank(alice);
        bool success = token.approve(bob, aliceApproveAmount);
        assert(success);
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20.ERC20InsufficientAllowance.selector, bob, aliceApproveAmount, aliceApproveAmount + 1
            )
        );
        bool transferSuccess = token.transferFrom(alice, charlie, aliceApproveAmount + 1);
        assert(!transferSuccess);
        vm.stopPrank();
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
