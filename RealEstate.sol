// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./API.sol";


/// @title RealEstate smart-contract
/// @author Клейменов А. А., Толстенко Л. С.

/**
 * @dev Характеризует имущество (недвижимость)
 */ 
struct Property {
    /**
     * @dev Ссылка на документ о владении, 
     * @dev кадастровый номер,
     * @dev стоимость имущества в wei,
     * @dev статус продажи имущества
     */ 
    string document;
    string cadastralNumber;
    uint256 cost;
    bool isSelling;
}


/**
 * @dev Характеризует транзацию создания токена, продажи и уничтожения
 */ 
struct Transaction {
    /**
     * @dev Отправитель токена, 
     * @dev получатель токена,
     * @dev ID токена,
     * @dev стоимость токена в wei
     */ 
    address from;
    address to;
    uint256 tokenId;
    uint256 cost;
}


/**
 * @dev Токен смарт-контракта RealEstate
 */
contract RESToken is ERC721 {
    /**
     * @dev сопоставление ID токена с property, 
     * @dev количество существующих токенов в смарт-контракте,
     * @dev индекс последнего созданного токена
     */
    mapping(uint256 => Property) tokens;
    uint256 public totalSupply = 0;
    uint256 maxTokenId = 0;

    constructor() ERC721("RESToken", "REST") {}

    /**
    * @dev Возвращает ссылку на документ владения имущества
    * 
    * @param tokenId ID токена
    * @return ссылка на документ
    */
    function tokenURI(uint256 tokenId) external view override requireMinted(tokenId) returns(string memory) {
        return tokens[tokenId].document;
    }
}


/**
 * @dev Cмарт-контракта RealEstate
 */
contract RealEstate is RESToken, API {
    /**
     * @dev сопоставление адреса с фактом прохождения верификации.
     * @dev сопоставление timestamp с конкретной транзакцией
     */ 
    mapping(address => bool) verificated;
    mapping(uint256 => Transaction) public history;

    event TokenConstructed(address indexed owner, uint256 indexed tokenId);

    constructor() RESToken() {}

    /**
    * @dev Создаёт токен RESToken верифицированного пользователя с заданными параметрами
    * 
    * @param document Ссылка на документ property создаваемого токена
    * @param cost Желаемая цена продажи
    * @param login Логин верифицируемого пользователя на сайте Госуслуг
    * @param password Пароль верифицируемого пользователя на сайте Госуслуг
    */
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

    /**
    * @dev Верифицирует пользователя
    * 
    * @param login Логин верифицируемого пользователя на сайте Госуслуг
    * @param password Пароль верифицируемого пользователя на сайте Госуслуг
    */
    function verifyMe(string memory login, string memory password) public {
        require(verifyUser(login, password), "User verification failed!");
        verificated[msg.sender] = true;
    }

    /**
    * @dev Устанавивает флаг продажи токена
    * 
    * @param tokenId ID токена
    */
    function startSelling(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Operator not approved and sender is not an owner!");
        tokens[tokenId].isSelling = true;
    }

    /**
    * @dev Снимает флаг продажи токена
    * 
    * @param tokenId ID токена
    */
    function stopSelling(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Operator not approved and sender is not an owner!");
        tokens[tokenId].isSelling = false;
    }

    /**
    * @dev Устанавливает новую стоимость токена
    * 
    * @param tokenId ID токена
    * @param new_cost Новая стоимость токена
    */
    function setPropertyCost(uint256 tokenId, uint256 new_cost) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Operator not approved and sender is not an owner!");
        tokens[tokenId].cost = new_cost;
    }

    /**
    * @dev Возвращает ID всех токенов, принадлежащих данному адресу
    * 
    * @param owner Проверяемый адрес
    * @return Массив ID токенов
    */
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


    /**
    * @dev Возвращает property токена с данным ID
    * 
    * @param tokenId ID токена
    * @return property
    */
    function propertyOf(uint tokenId) public view returns(Property memory) {
        return tokens[tokenId];
    }


    /**
    * @dev Уничтожает токен с заданным ID
    * 
    * @param tokenId ID токена
    */
    function burnToken(uint256 tokenId) public requireMinted(tokenId) {
        _burn(tokenId);

        totalSupply -= 1;
        delete tokens[tokenId];
        _addHistoryTransaction(msg.sender, address(0), tokenId, tokens[tokenId].cost);
    }

    /**
    * @dev Безопасная передача токена в соответствии с ERC721
    * 
    * @param from Адрес отправителя токена
    * @param to ID Адрес получателя токена
    * @param tokenId ID токена
    */
    function safeTransferFrom(address from, address to, uint256 tokenId) public override payable {
        _beforeTransfer(tokenId);
        address payable toOwner = payable(ownerOf(tokenId));
        toOwner.transfer(msg.value);

        super.safeTransferFrom(from, to, tokenId);
        updateOwnerInfo(tokens[tokenId].document);
        _addHistoryTransaction(from, to, tokenId, tokens[tokenId].cost);
    }

    /**
    * @dev Обычная передача токена в соответствии с ERC721
    * 
    * @param from Адрес отправителя токена
    * @param to ID Адрес получателя токена
    * @param tokenId ID токена
    */
    function transferFrom(address from, address to, uint256 tokenId) public override payable {            
        _beforeTransfer(tokenId);
        address payable toOwner = payable(ownerOf(tokenId));
        toOwner.transfer(msg.value);

        super.transferFrom(from, to, tokenId);
        updateOwnerInfo(tokens[tokenId].document);
        _addHistoryTransaction(from, to, tokenId, tokens[tokenId].cost);
    }

    /**
    * @dev Осуществляет проверки перед передачей токена
    * 
    * @param tokenId ID токена
    */
    function _beforeTransfer(uint256 tokenId) internal {
        require(verificated[msg.sender], "Please, pass verification by calling verifyMe()!");
        require(tokens[tokenId].isSelling == true, "Property is not selling now!");
        require(msg.value >= tokens[tokenId].cost, "Not enough money to buy token!");
    }

    /**
    * @dev Добавляет транзакцию в историю транзакций
    * 
    * @param from Адрес отправителя токена
    * @param to ID Адрес получателя токена
    * @param tokenId ID токена
    * @param cost Стоимость токена
    */
    function _addHistoryTransaction(address from, address to, uint256 tokenId, uint256 cost) internal {
        history[block.timestamp] = Transaction({
            from:       from,
            to:         to,
            tokenId:    tokenId,
            cost:       cost
        });
    }


    fallback() external {
        revert("Operation does not allowed!");
    }
}
