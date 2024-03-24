// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Lquix {
    struct LiquidityRequest {
        address requester;
        uint amount;
        uint dueDate; // Unix timestamp of when the repayment is due
        bool isFulfilled;
        bool isRepaid;
    }

    struct LiquidityProvider {
        address provider;
        uint amountProvided;
    }

    uint public constant feePercentage = 5;
    address public owner;
    IERC20 public stableCoin;
    uint public constant monthlyInsuranceFee = 10 * 10 ** 6; // Assuming USDC has 6 decimals

    LiquidityRequest[] public requests;
    mapping(uint => LiquidityProvider) public providers;
    mapping(address => uint) public lastInsurancePayment;

    event RequestCreated(uint indexed requestId, address requester, uint amount, uint dueDate);
    event RequestFulfilled(uint indexed requestId, address provider, uint amount);
    event RepaymentReceived(uint indexed requestId, uint amountRepaid);

    constructor(address _stableCoinAddress) {
        owner = msg.sender;
        stableCoin = IERC20(_stableCoinAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function createRequest(uint _amount, uint _dueDate) public {
        require(_dueDate > block.timestamp, "Due date must be in the future");
        requests.push(LiquidityRequest({
            requester: msg.sender,
            amount: _amount,
            dueDate: _dueDate,
            isFulfilled: false,
            isRepaid: false
        }));
        uint requestId = requests.length - 1;
        emit RequestCreated(requestId, msg.sender, _amount, _dueDate);
    }

    function fulfillRequest(uint _requestId) public payable {
        require(_requestId < requests.length, "Request does not exist");
        LiquidityRequest storage request = requests[_requestId];
        require(!request.isFulfilled, "Request already fulfilled");
        
        uint fee = msg.value * feePercentage / 100;
        uint amountAfterFee = msg.value - fee;

        require(amountAfterFee == request.amount, "Incorrect amount provided");
        request.isFulfilled = true;
        providers[_requestId] = LiquidityProvider({
            provider: msg.sender,
            amountProvided: amountAfterFee
        });

        payable(owner).transfer(fee);
        payable(request.requester).transfer(amountAfterFee);

        emit RequestFulfilled(_requestId, msg.sender, amountAfterFee);
    }

    function repay(uint _requestId) public {
        LiquidityRequest storage request = requests[_requestId];
        require(request.isFulfilled, "Request not fulfilled");
        require(!request.isRepaid, "Already repaid");
        require(msg.sender == request.requester, "Only the requester can repay");

        request.isRepaid = true;

        emit RepaymentReceived(_requestId, request.amount);
    }

    function payMonthlyInsuranceFee() external {
        stableCoin.transferFrom(msg.sender, owner, monthlyInsuranceFee);
        lastInsurancePayment[msg.sender] = block.timestamp;
    }

    // Additional functions like withdrawing fees by the owner could be implemented here.
}
