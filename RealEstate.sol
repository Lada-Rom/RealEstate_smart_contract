// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ERC20.sol";


contract RESToken is ERC20 {
    //====== constructor ======
    constructor(address shop) ERC20("RESToken", "REST", 1, shop) {}
}


struct Property {
    string ownership;
    uint256 price;
    bool isSelling;
}


//["https://property.pdf", 1, true]
contract RealEstate is RESToken {
    address public address_shop;
    Property public property;

    event Bought(address indexed buyer, uint256 cost, uint256 timestamp);

    //====== constructor ======
    constructor(Property memory prop) RESToken(address(this)) {
        address_shop = address(this);
        address_owner = payable(msg.sender);
        property = prop;
    }


    //====== notOwner ======
    modifier notOwner() {
        require(msg.sender != address_owner, "Owner is not allowed to perform this operation!");
        _;
    }


    //====== startSelling ======
    function startSelling() external onlyOwner {
        property.isSelling = true;
    }

    //====== stopSelling ======
    function stopSelling() external onlyOwner {
        property.isSelling = false;
    }


    //====== setPrice ======
    function setPrice(uint256 new_price) external onlyOwner {
        property.price = new_price;
    }


    //====== buyProperty ======
    function buyProperty() external notOwner payable {
        address address_buyer = msg.sender;
        require(property.isSelling == true, "Property is not selling now!");
        require(msg.value >= property.price, "Not enough money to buy token!");

        transferFrom(address_owner, address_buyer, balanceOf(address_owner));

        address payable toOwner = payable(address_owner);
        toOwner.transfer(msg.value);

        address_owner = address_buyer;
        emit Bought(address_buyer, msg.value, block.timestamp);
    }
}
