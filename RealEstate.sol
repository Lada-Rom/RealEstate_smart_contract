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
    }

}
