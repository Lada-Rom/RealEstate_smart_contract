// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IERC721 {
    /*
     William Entriken (@fulldecent), Dieter Shirley <dete@axiomzen.co>, Jacob Evans <jacob@dekz.net>, Nastassia Sachs <nastassia.sachs@protonmail.com>, 
     "ERC-721: Non-Fungible Token Standard," Ethereum Improvement Proposals, no. 721, January 2018. [Online serial]. 
     Available: https://eips.ethereum.org/EIPS/eip-721.
    */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns(uint256);
    function ownerOf(uint tokenId) external view returns(address);

    function safeTransferFrom(address from, address to, uint256 tokenId) external payable;
    function transferFrom(address from, address to, uint256 tokenId) external payable;

    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns(address);
    function isApprovedForAll(address owner, address operator) external view returns(bool);

    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function tokenURI(uint256 tokenId) external view returns(string memory);
}


interface IERC721Receiver {
    function onERC721Received (
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns(bytes4);
}


contract ERC721 is IERC721 {
    string public name;
    string public symbol;

    mapping(address => uint256) balances;
    mapping(uint256 => address) owners;
    mapping(uint256 => address) tokenApprovals; //выдано разрешение кому-то взаимодействовать с моим токеном
    mapping(address => mapping(address => bool)) operatorApprovals; //кто-то может или не может управлять всеми токенами владельца


    modifier requireMinted(uint256 tokenId) {
        require(_exists(tokenId), "Token does not exists!");
        _;
    }


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }


    function tokenURI(uint256 tokenId) external view virtual requireMinted(tokenId) returns(string memory) {
        return "";
    }


    function balanceOf(address owner) external view returns(uint256) {
        require(owner != address(0), "Zero address is not allowed!");
        return balances[owner];
    }

    function ownerOf(uint tokenId) public view requireMinted(tokenId) returns(address) {
        return owners[tokenId];
    }


    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual payable {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved and sender is not an owner!");
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId), "Receiver cannot own the token!");
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual payable {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved and sender is not an owner!");
        _transfer(from, to, tokenId);
    }


    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(owner == msg.sender || isApprovedForAll(owner, msg.sender), "Not an owner!");
        require(to != owner, "Self approving is not allowed!");
        tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(msg.sender != operator, "Self approving is not allowed!");
        operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) public view requireMinted(tokenId) returns(address) {
        return tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns(bool) {
        return operatorApprovals[owner][operator];
    }


    function _exists(uint256 tokenId) internal view returns(bool) {
        return owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address from, uint256 tokenId) internal view returns(bool) {
        address owner = ownerOf(tokenId);
        return (
            from == owner ||
            isApprovedForAll(owner, from) ||
            getApproved(tokenId) == from
        );
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(to != from, "Self transfer is not allowed!");
        require(to != address(0), "Transfer to zero address is not allowed!");

        balances[from] -= 1;
        balances[to] += 1;
        owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId) internal returns(bool) {
        if(to.code.length > 0) {
            //return IERC721Receiver.onERC721Received.selector
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, bytes("")) returns(bytes4 ret) {
                return ret == IERC721Receiver.onERC721Received.selector;
            }
            catch(bytes memory reason) {
                if(reason.length == 0)
                    revert("Non ERC721 receiver!");
                else
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
            }
        }
        else {
            return true;
        }
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(msg.sender, to, tokenId), "Non ERC721 receiver!");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "Receiver cannot be zero address!");
        require(!_exists(tokenId), "Already exists!");

        owners[tokenId] = to;
        balances[to] += 1;
    }

    function _burn(uint256 tokenId) internal virtual {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved and sender is not an owner!");
        address owner = ownerOf(tokenId);

        delete tokenApprovals[tokenId];
        balances[owner] -= 1;
        delete owners[tokenId];
    }
}
