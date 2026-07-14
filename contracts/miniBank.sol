// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MyMiniBank {

    error NotOwner();
    error UserHasAlreadyRegistered();
    error OnlyVisitor();
    error UserHasNotRegisteredYet();
    error NotEnoughMoney();

    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);

    uint256 public nextId = 1;
    address public owner;

    ///@notice userId => userbalance
    mapping (uint256 => uint256) public userBalance;

    ///@notice address => address to ID
    mapping (address => uint256) public userAddressToID;

    ///@notice address => ID to address
    mapping (uint256 => address) public idToUserAddress;
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, NotOwner());
        _;
    }

    modifier onlyVisitor() {
        require(owner != msg.sender, OnlyVisitor());
        _;
    }

    function registration() public onlyVisitor{
        require(userAddressToID[msg.sender] == 0, UserHasAlreadyRegistered());
        idToUserAddress[nextId] = msg.sender;
        userAddressToID[msg.sender] = nextId;
        nextId++;
    }

    function getBalance(uint256 _id) public view returns(uint256) {
         return userBalance[_id];
    }

    function getBankBalance() public view onlyOwner returns(uint256) {
        return address(this).balance;
    }

    function deposit() public payable {
        uint256 currentId = userAddressToID[msg.sender];
        require(currentId != 0, UserHasNotRegisteredYet());
        userBalance[currentId] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public {
        uint256 newCurrentId = userAddressToID[msg.sender]; 
        require(newCurrentId != 0, UserHasNotRegisteredYet());
        require(_amount <= userBalance[newCurrentId], NotEnoughMoney());
        userBalance[newCurrentId] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }

}