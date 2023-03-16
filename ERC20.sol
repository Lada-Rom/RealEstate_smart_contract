// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns(string memory);
    function symbol() external view returns (string memory);
    function decimals() external pure returns(uint256);

    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address to, uint256 amount) external;

    function allowance(address _owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approve(address indexed owner, address indexed to, uint256 amount);
}

contract ERC20 is IERC20 {
    address public address_owner;
    uint256 totalTokens;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    string _name;
    string _symbol;


    //====== constructor ======
    constructor(string memory name_, string memory symbol_, uint256 initialSupply, address shop) {
        _name = name_;
        _symbol = symbol_;
        address_owner = msg.sender;
        mint(shop, initialSupply);

        balances[shop] -= initialSupply;
        balances[address_owner] += initialSupply;
    }


    //====== name ======
    function name() external view returns(string memory) {
        return _name;
    }

    //====== symbol ======
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    //====== decimals ======
    function decimals() external pure returns(uint256) {
        return 18;
    }


    //====== totalSupply ======
    function totalSupply() public view returns(uint256) {
        return totalTokens;
    }

    //====== balanceOf ======
    function balanceOf(address account) public view returns(uint256) {
        return balances[account];
    }

    //====== transfer ======
    function transfer(address to, uint256 amount) external enoughTokens(msg.sender, amount) {
        _beforeTokenTransfer(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }


    //====== allowance ======
    function allowance(address _owner, address spender) public view returns(uint256) {
        return allowances[_owner][spender];
    }

    //====== approve ======
    function approve(address spender, uint256 amount) public {
        _approve(msg.sender, spender, amount);
        emit Approve(msg.sender, spender, amount);
    }

    //====== transferFrom ======
    function transferFrom(address sender, address recipient, uint256 amount) public enoughTokens(sender, amount) {
        _beforeTokenTransfer(sender, recipient, amount);

        require(allowances[sender][recipient] >= amount, "Such amount not allowed!");
        allowances[sender][recipient] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }


    //====== onlyOwner ======
    modifier onlyOwner() {
        require(msg.sender == address_owner, "Not an owner!");
        _;
    }

    //====== enoughTokens ======
    modifier enoughTokens(address _from, uint256 amount) {
        require(balanceOf(_from) >= amount, "Not enough tokens!");
        _;
    }


    //====== _beforeTokenTransfer ======
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    //====== _approve ======
    function _approve(address sender, address spender, uint256 amount) internal virtual {
        allowances[sender][spender] = amount;
    }


    //====== mint ======
    function mint(address shop, uint256 amount) public onlyOwner {
        _beforeTokenTransfer(address(0), shop, amount);
        balances[shop] += amount;
        totalTokens += amount;
        emit Transfer(address(0), shop, amount);
    }

    //====== burn ======
    function burn(address shop, uint256 amount) public onlyOwner enoughTokens(shop, amount) {
        _beforeTokenTransfer(shop, address(0), amount);
        balances[shop] -= amount;
        totalTokens -= amount;
    }
}
