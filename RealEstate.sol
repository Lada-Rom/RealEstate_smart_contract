// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ERC20.sol";


contract RESToken is ERC20 {
    constructor(address shop) ERC20("RESToken", "REST", 1, shop) {}
}


contract RealEstate {
    IERC20 public token;
    address payable public owner;

    event Bought(address indexed buyer, uint256 amount);
    event Sold(address indexed seller, uint256 amount);

    //====== constructor ======
    constructor() {
        token = new RESToken(address(this));
        owner = payable(msg.sender);
    }

    //====== onlyOwner ======
    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    //====== sell ======
    function sell(uint256 amountToSell) external {
        require(amountToSell > 0, "Zero tokens are not allowed");
        require(token.balanceOf(msg.sender) >= amountToSell, "Not enough tokens to sell!");

        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amountToSell, "Such amount not allowed!");

        token.transferFrom(msg.sender, address(this), amountToSell);
        payable(msg.sender).transfer(amountToSell); // 1 token = 1 wei
        emit Sold(msg.sender, amountToSell);
    }

    //====== receive ======
    receive() external payable {
        uint256 tokensToBuy = msg.value; // 1 token = 1 wei
        require(tokensToBuy > 0, "Zero tokens are not allowed");
        require(tokenBalance() >= tokensToBuy, "Too much tokens to buy!");
    
        token.transfer(msg.sender, tokensToBuy);
        emit Bought(msg.sender, tokensToBuy);
    }

    //====== tokenBalance ======
    function tokenBalance() public view returns(uint256) {
        return token.balanceOf(address(this));
    }
}
