// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./API.sol";


struct Property {
    string document;
    string cadastralNumber;
    uint256 cost;
    bool isSelling;
}


struct Transaction {
    address from;
    address to;
    uint256 tokenId;
    uint256 cost;
}


contract RESToken is ERC721 {
    mapping(uint256 => Property) tokens;
    uint256 public totalSupply = 0;
    uint256 maxTokenId = 0;

    constructor() ERC721("RESToken", "REST") {}

    function tokenURI(uint256 tokenId) external view override requireMinted(tokenId) returns(string memory) {
        return tokens[tokenId].document;
    }
}


contract RealEstate is RESToken, API {
    mapping(address => bool) verificated;
    mapping(uint256 => Transaction) history;

    event TokenConstructed(address indexed owner, uint256 indexed tokenId);

    constructor() RESToken() {}

    function constructToken(string memory document, uint256 cost, string memory login, string memory password) external {
        //verify sender with gosuslugi (login, password)
        require(verifyUser(login, password), "User does not exists!");

        //get passport data from gosuslugi
        uint256 passport_data = getPassportData(login, password);

        //get cadastral number from document
        string memory cadastral = getCadastralNumberFromDoc(document);

        //verify if 1) cadastral number is valid and 2) user with his passport data owns this property
        require(validateCadastrialNumber(cadastral), "Cadastral number is not valid!");
        require(checkOwneship(cadastral, passport_data), "User does not own this property!");

        totalSupply += 1;
        maxTokenId += 1;
        uint256 tokenId = maxTokenId;
        tokens[tokenId] = Property({
            document: document,
            cadastralNumber: cadastral,
            cost: cost,
            isSelling: true});
        _safeMint(msg.sender, tokenId);

        emit TokenConstructed(msg.sender, tokenId);
        _addHistoryTransaction(address(0), msg.sender, tokenId, cost);
    }

    function verifyMe(string memory login, string memory password) public {
        require(verifyUser(login, password), "User verification failed!");
        verificated[msg.sender] = true;
    }

    function startSelling(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Operator not approved and sender is not an owner!");
        tokens[tokenId].isSelling = true;
    }

    function stopSelling(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Operator not approved and sender is not an owner!");
        tokens[tokenId].isSelling = false;
    }

    function setPropertyCost(uint256 tokenId, uint256 new_cost) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Operator not approved and sender is not an owner!");
        tokens[tokenId].cost = new_cost;
    }

    function getAllTokens(address owner) public view returns(uint256[] memory) {
        uint256 tokenIdQuantity = 0;
        for(uint8 tokenId = 1; tokenId <= maxTokenId; tokenId += 1)
            if(_exists(tokenId) && ownerOf(tokenId) == owner)
                tokenIdQuantity += 1;

        uint256[] memory tokensList = new uint256[](tokenIdQuantity);
        uint256 tokenCurr = 0;
        for(uint8 tokenId = 1; tokenId <= maxTokenId; tokenId += 1) {
            if(_exists(tokenId) && ownerOf(tokenId) == owner) {
                tokensList[tokenCurr] = tokenId;
                tokenCurr += 1;
            }                
        }

        return tokensList;
    }


    function propertyOf(uint tokenId) public view requireMinted(tokenId) returns(Property memory) {
        return tokens[tokenId];
    }


    function burnToken(uint256 tokenId) public {
        _burn(tokenId);

        totalSupply -= 1;
        delete tokens[tokenId];
        _addHistoryTransaction(msg.sender, address(0), tokenId, tokens[tokenId].cost);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override payable {
        _beforeTransfer(tokenId);
        address payable toOwner = payable(ownerOf(tokenId));
        toOwner.transfer(msg.value);

        super.safeTransferFrom(from, to, tokenId);
        updateOwnerInfo(tokens[tokenId].document);
        _addHistoryTransaction(from, to, tokenId, tokens[tokenId].cost);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override payable {            
        _beforeTransfer(tokenId);
        address payable toOwner = payable(ownerOf(tokenId));
        toOwner.transfer(msg.value);

        super.transferFrom(from, to, tokenId);
        updateOwnerInfo(tokens[tokenId].document);
        _addHistoryTransaction(from, to, tokenId, tokens[tokenId].cost);
    }

    function _beforeTransfer(uint256 tokenId) internal {
        require(verificated[msg.sender], "Please, pass verification by calling verifyMe()!");
        require(tokens[tokenId].isSelling == true, "Property is not selling now!");
        require(msg.value >= tokens[tokenId].cost, "Not enough money to buy token!");
    }

    function _addHistoryTransaction(address from, address to, uint256 tokenId, uint256 cost) internal {
        history[block.timestamp] = Transaction({
            from:       from,
            to:         to,
            tokenId:    tokenId,
            cost:       cost
        });
    }
}
