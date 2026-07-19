// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title MyMiniBank
 * @dev Implements basic banking: deposits, 10-minute interval rewards, 
 *      withdrawals with fees, and anti-spam protection.
 */
contract MyMiniBank {

    error NotOwner();
    error UserHasAlreadyRegistered();
    error UserHasNotRegisteredYet();
    error NotEnoughMoney();
    error AmountTooSmall();
    error TransferFailed();
    error TimeLocked();
    error BankInsufficientFunds();
    error AddressIsBlackListed();

    struct UserInfo {
        uint256 balance;
        uint256 depositTime;
        bool isRegistered;
    }

    // 'indexed' allows off-chain tools to filter events by these parameters efficiently.
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event RewardDistributed(address indexed user, uint256 amount);
    event AddressBlacklisted(address indexed user, bool status);

    uint256 public constant VIP_THRESHOLD = 2 ether;
    uint256 public totalProfit;
    address public owner;

    mapping (address => UserInfo) public users;
    mapping (address => bool) public isBlackListed;
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, NotOwner());
        _;
    }

    /// @notice Manages the blacklist status of users
    function blacklist(address _user, bool _isBlackListed) public onlyOwner {
        isBlackListed[_user] = _isBlackListed;
        emit AddressBlacklisted(_user, _isBlackListed);
    }

    /// @notice Internal logic to calculate and distribute 3% rewards every 10 minutes
    /// @dev Updates user balance and shifts depositTime based on completed intervals
    function _processRewards(address _user) internal {
        UserInfo storage user = users[_user];
        if (user.depositTime == 0 || user.balance == 0) return;
        
        uint256 timeElapsed = block.timestamp - user.depositTime;
        uint256 intervals = timeElapsed / 10 minutes;
        
        if (intervals > 0) {
            uint256 reward = ((user.balance * 3) / 1000) * intervals;
            require(address(this).balance >= (totalProfit + reward), BankInsufficientFunds());
            
            user.balance += reward;
            user.depositTime += (intervals * 10 minutes);
            emit RewardDistributed(_user, reward);
        }
    }

    /// @notice Registers a new user in the system
    function registration() public {
        require(!users[msg.sender].isRegistered, UserHasAlreadyRegistered());
        users[msg.sender] = UserInfo(0, 0, true);
    }

    /// @notice Withdraws the bank's accumulated fees (owner only)
    function claimProfit() public onlyOwner {
        uint256 currentTotalProfit = totalProfit;
        totalProfit = 0;
        (bool success, ) = payable(owner).call{value: currentTotalProfit}("");
        require(success, TransferFailed());
    }

    function getBankBalance() public view onlyOwner returns(uint256) {
        return address(this).balance;
    }

    function getUserInfo(address _user) external view returns(uint256 balance, uint256 depositTime) {
        return (users[_user].balance, users[_user].depositTime);
    }

    /// @notice Deposits ETH into the bank
    /// @dev Requires a 10-minute cooldown between deposits if balance > 0
    function deposit() public payable {
        require(users[msg.sender].isRegistered, UserHasNotRegisteredYet());
        require(!isBlackListed[msg.sender], AddressIsBlackListed());
        
        UserInfo storage user = users[msg.sender];
        if (user.balance > 0) {
            require(block.timestamp >= user.depositTime + 10 minutes, TimeLocked());
        }
        
        _processRewards(msg.sender);
        
        if (user.depositTime == 0) {
            user.depositTime = block.timestamp;
        }
        
        user.balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraws funds from the bank
    /// @dev Fees: 1% for VIP (>= 2 ETH), 5% for regular users. 10-minute cooldown applied.
    function withdraw(uint256 _amount) public {
        UserInfo storage user = users[msg.sender];
        require(user.isRegistered, UserHasNotRegisteredYet());
        require(!isBlackListed[msg.sender], AddressIsBlackListed());
        require(_amount <= user.balance, NotEnoughMoney());
        require(_amount >= 20, AmountTooSmall());
        
        require(block.timestamp >= user.depositTime + 10 minutes, TimeLocked());
        
        _processRewards(msg.sender);
        
        uint256 profit = (user.balance >= VIP_THRESHOLD) ? (_amount / 100) : (_amount / 20);
        
        user.balance -= _amount;
        totalProfit += profit;
        user.depositTime = block.timestamp;
        
        (bool success, ) = payable(msg.sender).call{value: _amount - profit}("");
        require(success, TransferFailed());
        
        emit Withdraw(msg.sender, _amount);
    }
}