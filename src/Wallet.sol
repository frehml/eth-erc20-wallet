// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Wallet {
    mapping(address => bool) public whitelisted;

    // Payable address can receive Ether
    address payable public admin;
    address payable public algo;

    // Payable constructor can receive Ether
    constructor(address _admin, address _algo) {
        admin = payable(_admin);
        algo = payable(_algo);
    }

    function depositToken(address token, uint256 _amount) public payable {
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
    }

    // Function to withdraw all ERC20 token from this contract.
    function withdrawToken(address token) public onlyAdmin {
        IERC20(token).transferFrom(
            address(this),
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }

    // Function to transfer ERC20 from this contract to address from input
    function transferToken(
        address token,
        address payable _to,
        uint256 _amount
    ) public onlyAlgo isWhitelisted(_to) {
        IERC20(token).transferFrom(address(this), _to, _amount);
    }

    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function depositEth() public payable {}

    // Function to withdraw all Ether from this contract.
    function withdrawEth() public {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = admin.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to transfer Ether from this contract to address from input
    function transferEth(address payable _to, uint256 _amount)
        public
        onlyAlgo
        isWhitelisted(_to)
    {
        // Note that "to" is declared as payable
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    function setAdmin(address payable _admin) public onlyAdmin {
        admin = _admin;
    }

    function setAlgo(address payable _algo) public onlyAdmin {
        algo = _algo;
    }

    function whitelistAddress(address addy) public onlyAdmin {
        whitelisted[addy] = true;
    }

    function whitelistAddresses(address[] calldata addys) public onlyAdmin {
        for (uint256 i = 0; i < addys.length; i++) {
            whitelisted[addys[i]] = true;
        }
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    modifier onlyAlgo() {
        require(msg.sender == algo, "Not algo");
        _;
    }

    modifier isWhitelisted(address addy) {
        require(whitelisted[addy], "Not whitelisted");
        _;
    }

    function getEthBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}
