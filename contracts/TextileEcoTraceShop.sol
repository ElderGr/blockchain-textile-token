//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface TextileEcoTraceTokenInterface is IERC20 {
    function mint(address account, uint256 amount) external returns (bool);
}

contract TextileEcoTraceShop {
    AggregatorV3Interface internal priceFeed;
    TextileEcoTraceTokenInterface public minter;
    uint256 public tokenPrice = 2000; //1 token = 20.00 usd, with 2 decimal places
    address public owner;

    constructor(address tokenAddress){
        minter = TextileEcoTraceTokenInterface(tokenAddress);

        priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        owner = msg.sender;
    }

    function getLatestPrice() public view returns (int){
        ( ,int price,,,) = priceFeed.latestRoundData();
        return price;
    }

    function tokenAmount(uint256 amountETH) public view returns (uint256){
        uint256 ethUsd = uint256(getLatestPrice());
        uint256 amountUSD = amountETH * ethUsd / 1000000000000000000; 
        uint256 amountToken = amountUSD / tokenPrice / 100;
        return amountToken;
    }   

    function sendTokens(address _to, uint256 _amount) external onlyOwner {
        uint256 amountToken = tokenAmount(_amount);
        require(minter.balanceOf(address(this)) >= amountToken, "Insufficient balance");
        require(minter.transfer(_to, amountToken), "Transfer failed");
    }    

    receive() external payable {
        uint256 amountToken = tokenAmount(msg.value);
        minter.mint(msg.sender, amountToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}