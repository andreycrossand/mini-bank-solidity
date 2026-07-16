// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MyMiniBank {

    error NotOwner();
    error UserHasAlreadyRegistered();
    error OnlyVisitor();
    error UserHasNotRegisteredYet();
    error NotEnoughMoney();
    error AmountTooSmall();
    error TransferFailed();
    error TimeLocked();

    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);

    uint256 public constant VIP_THRESHOLD = 2 ether;
    uint256 public nextId = 1;
    uint256 public totalProfit = 0;
    address public owner;

    ///@notice userId => userbalance
    mapping (uint256 => uint256) public userBalance;

    ///@notice address => address to ID
    mapping (address => uint256) public userAddressToID;

    ///@notice address => ID to address
    mapping (uint256 => address) public idToUserAddress;

    ///@notice ID to time last deposit
    mapping (uint256 => uint256) public depositTime;
    
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

    function claimProfit() public onlyOwner {
        uint256 currentTotalProfit = totalProfit;
        totalProfit = 0;
        (bool success, ) = payable(owner).call{value: currentTotalProfit}("");
        require(success, TransferFailed());
    }

    function getBalance(uint256 _id) public view returns(uint256) {
         return userBalance[_id];
    }

    function getBankBalance() public view onlyOwner returns(uint256) {
        return address(this).balance;
    }

    function getStatus() public view returns(string memory) {
        if (userBalance[userAddressToID[msg.sender]] >= VIP_THRESHOLD){
            return "You are vip user";
        }

        else {
            return "You are poor user";
        }
    }

    function deposit() public payable {
        uint256 currentId = userAddressToID[msg.sender];
        require(currentId != 0, UserHasNotRegisteredYet());
        if (depositTime[currentId] != 0) {
            require(block.timestamp >= 10 minutes + depositTime[currentId], TimeLocked());
        }
        userBalance[currentId] += msg.value;
        depositTime[currentId] = block.timestamp;
        emit Deposit(msg.sender, msg.value);
    }

    ///@dev withdraw with bank fee (5 %)
    function withdraw(uint256 _amount) public {
        uint256 profit = 0;
        uint256 newCurrentId = userAddressToID[msg.sender]; 
        require(newCurrentId != 0, UserHasNotRegisteredYet());
        require(_amount <= userBalance[newCurrentId], NotEnoughMoney());
        require(_amount >= 20, AmountTooSmall());
        if(depositTime[newCurrentId] != 0) {
            require(block.timestamp >= 10 seconds + depositTime[newCurrentId], TimeLocked());
        }
        if (userBalance[newCurrentId] >= VIP_THRESHOLD) {
            profit = _amount / 100;
        }

        else {
            profit = _amount / 20;
        }
        userBalance[newCurrentId] -= _amount;
        totalProfit += profit;
        (bool success, ) = payable(msg.sender).call{value: _amount - profit}("");
        require(success, TransferFailed());
        depositTime[newCurrentId] = block.timestamp;
        emit Withdraw(msg.sender, _amount);
    }
}