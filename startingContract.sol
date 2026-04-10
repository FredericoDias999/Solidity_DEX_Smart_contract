// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DecentralizedFinance is ERC20 {
    // TODO: define variables

    event loanCreated(address borrower, uint256 amount, uint256 deadline);


    constructor() ERC20("DEX", "DEX") {
        _mint(address(this), 10**18);

        // TODO: initialize
    }

    function buyDex() external payable {
        // TODO: implement this
    }

    function sellDex(uint256 dexAmount) external {
        // TODO: implement this
    }

    function loan(uint256 dexAmount, uint256 deadline) external {
        // TODO: implement this

    }

    //TODO: implement the rest
}