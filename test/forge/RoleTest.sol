// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./helpers/BaseTest.sol";

contract RoleTest is BaseTest {
    using MarketParamsLib for MarketParams;

    function testOwnerFunctionsShouldRevertWhenNotOwner(address caller) public {
        vm.assume(caller != vault.owner());
        vm.startPrank(caller);

        vm.expectRevert("Ownable: caller is not the owner");
        vault.submitTimelock(TIMELOCK);

        vm.expectRevert("Ownable: caller is not the owner");
        vault.acceptTimelock();

        vm.expectRevert("Ownable: caller is not the owner");
        vault.setIsRiskManager(caller, true);

        vm.expectRevert("Ownable: caller is not the owner");
        vault.setIsAllocator(caller, true);

        vm.expectRevert("Ownable: caller is not the owner");
        vault.submitFee(1);

        vm.expectRevert("Ownable: caller is not the owner");
        vault.acceptFee();

        vm.expectRevert("Ownable: caller is not the owner");
        vault.setFeeRecipient(caller);

        vm.stopPrank();
    }

    function testRiskManagerFunctionsShouldRevertWhenNotRiskManagerAndNotOwner(address caller) public {
        vm.assume(caller != vault.owner() && !vault.isRiskManager(caller));
        vm.startPrank(caller);

        vm.expectRevert(bytes(ErrorsLib.NOT_RISK_MANAGER));
        vault.submitCap(allMarkets[0], CAP);

        vm.expectRevert(bytes(ErrorsLib.NOT_RISK_MANAGER));
        vault.acceptCap(allMarkets[0].id());

        vm.stopPrank();
    }

    function testAllocatorFunctionsShouldRevertWhenNotAllocatorAndNotRiskManagerAndNotOwner(address caller) public {
        vm.assume(caller != vault.owner() && !vault.isRiskManager(caller) && !vault.isAllocator(caller));
        vm.startPrank(caller);

        Id[] memory order;
        MarketAllocation[] memory allocation;

        vm.expectRevert(bytes(ErrorsLib.NOT_ALLOCATOR));
        vault.setSupplyQueue(order);

        vm.expectRevert(bytes(ErrorsLib.NOT_ALLOCATOR));
        vault.setWithdrawQueue(order);

        vm.expectRevert(bytes(ErrorsLib.NOT_ALLOCATOR));
        vault.reallocate(allocation, allocation);

        vm.stopPrank();
    }

    function testRiskManagerOrOwnerShouldTriggerRiskManagerFunctions() public {
        vm.startPrank(OWNER);
        vault.submitCap(allMarkets[0], CAP);
        vault.acceptCap(allMarkets[0].id());
        vm.stopPrank();

        vm.startPrank(RISK_MANAGER);
        vault.submitCap(allMarkets[1], CAP);
        vault.acceptCap(allMarkets[1].id());
        vm.stopPrank();
    }

    function testAllocatorOrRiskManagerOrOwnerShouldTriggerAllocatorFunctions() public {
        Id[] memory order = new Id[](1);
        order[0] = allMarkets[0].id();
        MarketAllocation[] memory allocation;

        _submitAndAcceptCap(allMarkets[0], CAP);

        vm.startPrank(OWNER);
        vault.setSupplyQueue(order);
        vault.setWithdrawQueue(order);
        vault.reallocate(allocation, allocation);
        vm.stopPrank();

        vm.startPrank(RISK_MANAGER);
        vault.setSupplyQueue(order);
        vault.setWithdrawQueue(order);
        vault.reallocate(allocation, allocation);
        vm.stopPrank();

        vm.startPrank(ALLOCATOR);
        vault.setSupplyQueue(order);
        vault.setWithdrawQueue(order);
        vault.reallocate(allocation, allocation);
        vm.stopPrank();
    }
}
