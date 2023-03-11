// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

//["http",1,true]
contract RealEstate {

    constructor(Property memory _property) {
        owner = msg.sender;
        property = _property;
        timestamp = block.timestamp;

        history.push(Transaction({
            new_owner: owner,
            timestamp: timestamp,
            property: property
        }));
    }

    address public owner = address(0);
    Property public property;
    uint256 public timestamp; //time of property acquisition

    Transaction[] public history;

    //=======startSelling=============
    function startSelling() external {
        require(msg.sender == owner, "Only owner can start property selling!");
        property.isSelling = true;
    }

    //=======stoptSelling=============
    function stopSelling() external {
        require(msg.sender == owner, "Only owner can stop property selling!");
        property.isSelling = false;
    }

    //=======setPrice=============
    function setPrice(uint256 new_price) external {
        require(msg.sender == owner, "Only owner can change property price!");
        property.price = new_price;
    }

    //=======buyProperty=============
    function buyProperty() external payable {
        address buyer = msg.sender;
        require(property.isSelling == true, "Property is not selling now!");
        require(owner != buyer, "Selfbuying is not allowed!");
        require(msg.value >= property.price, "Not enough money!");

        address payable toOwner = payable(owner);
        toOwner.transfer(msg.value);
        timestamp = block.timestamp;
        owner = buyer;

        history.push(Transaction({
            new_owner: owner,
            timestamp: timestamp,
            property: property
        }));
    }

    struct Property {
        string ownership;
        uint256 price;
        bool isSelling;
    }

    struct Transaction {
        address new_owner;
        uint256 timestamp;
        Property property;
    }
}
