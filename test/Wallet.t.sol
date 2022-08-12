// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./mocks/MockERC20.sol";
import "contracts/Wallet.sol";

contract ContractTest is Test {
    address admin = 0x00a329c0648769A73afAc7F9381E08FB43dBEA72;
    address algo = 0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8;

    Wallet public wallet;
    MockERC20 public mockToken;

    function setUp() public {
        mockToken = new MockERC20();
        wallet = new Wallet(admin, algo);
    }

    function testExample() public {
        assertTrue(true);
    }
}
