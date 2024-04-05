// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TextileEcoTrace is ERC20, Ownable {
    constructor(address initialOwner, uint256 initialSupply)
        ERC20("TextileEcoTrace", "TET")
        Ownable(initialOwner)
    {
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) public onlyOwner{
        _mint(to, amount);
    }
}