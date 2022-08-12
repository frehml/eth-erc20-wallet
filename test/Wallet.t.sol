// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "./mocks/MockERC20.sol";
import "contracts/Wallet.sol";

contract ContractTest is Test {
    address payable admin = payable(0x00a329c0648769A73afAc7F9381E08FB43dBEA72);
    address payable algo = payable(0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8);
    address payable non_whitelisted =
        payable(0xCD458d7F11023556cC9058F729831a038Cb8Df9c);
    address payable whitelisted =
        payable(0xC087629431256745e6e3d87B3EC14e8B42D47E48);

    Wallet public wallet;
    MockERC20 public mockToken;

    function setUp() public {
        vm.startPrank(admin);
        mockToken = new MockERC20();
        wallet = new Wallet(admin, algo);
        wallet.whitelistAddress(whitelisted);
    }

    function testDepositToken() public {
        mockToken.approve(address(wallet), 100);
        wallet.depositToken(address(mockToken), 100);
        assertTrue(wallet.getTokenBalance(address(mockToken)) == 100);
    }

    function testWithdrawToken() public {
        wallet.withdrawToken(address(mockToken));
        assertTrue(wallet.getTokenBalance(address(mockToken)) == 0);
    }

    function testDepositEth() public {
        wallet.depositEth{value: 1}();
        assertTrue(wallet.getEthBalance() == 1);
    }

    function testWithdrawEth() public {
        wallet.withdrawEth();
        assertTrue(wallet.getEthBalance() == 0);
    }

    function testTransferEthNotAlgo() public {
        vm.expectRevert(bytes("Not algo"));
        wallet.transferEth(non_whitelisted, 1);
    }

    function testTransferTokenNotAlgo() public {
        vm.expectRevert(bytes("Not algo"));
        wallet.transferToken(address(mockToken), non_whitelisted, 1);
    }

    function testTransferEthNonWhitelist() public {
        preliminaries();

        //test
        vm.expectRevert(bytes("Not whitelisted"));
        wallet.transferEth(non_whitelisted, 1);
    }

    function testTransferTokenNonWhitelist() public {
        preliminaries();

        vm.expectRevert(bytes("Not whitelisted"));
        wallet.transferToken(address(mockToken), non_whitelisted, 1);
    }

    function testTransferEth() public {
        preliminaries();

        //test
        wallet.transferEth(whitelisted, 1);
        assertTrue(whitelisted.balance == 1);
    }

    function testTransferToken() public {
        preliminaries();

        wallet.transferToken(address(mockToken), whitelisted, 1);
        assertTrue(mockToken.balanceOf(whitelisted) == 1);
    }

    function preliminaries() public {
        // preliminaries for the next functions
        wallet.depositEth{value: 10}();
        mockToken.approve(address(wallet), 100);
        wallet.depositToken(address(mockToken), 100);
        vm.stopPrank();
        vm.startPrank(algo);
    }
}
