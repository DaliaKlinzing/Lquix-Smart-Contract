// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Lquix {
    struct LiquidityRequest {
        address requester;
        uint amount;
        bool isFulfilled;
    }

    struct LiquidityProvider {
        address provider;
        uint amountProvided;
    }

    uint public constant feePercentage = 5; // 5% fee
    address public owner;
    IERC20 public stableCoin; // USDC or any other stablecoin contract
    uint public constant monthlyInsuranceFee = 10 * 10 ** 6; // Assuming USDC has 6 decimals

    LiquidityRequest[] public requests;
    mapping(uint => LiquidityProvider) public providers; // maps request index to provider
    mapping(address => uint) public lastInsurancePayment;

    event RequestCreated(uint requestId, address requester, uint amount);
    event RequestFulfilled(uint requestId, address provider, uint amount);

    constructor(address _stableCoinAddress) {
        owner = msg.sender;
        stableCoin = IERC20(_stableCoinAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function createRequest(uint _amount) public {
        require(lastInsurancePayment[msg.sender] + 30 days < block.timestamp, "Monthly insurance fee due");
        requests.push(LiquidityRequest({
            requester: msg.sender,
            amount: _amount,
            isFulfilled: false
        }));
        emit RequestCreated(requests.length - 1, msg.sender, _amount);
    }

    function fulfillRequest(uint _requestId) public payable {
        require(_requestId < requests.length, "Request does not exist");
        require(!requests[_requestId].isFulfilled, "Request already fulfilled");

        uint fee = msg.value * feePercentage / 100;
        uint amountAfterFee = msg.value - fee;

        require(amountAfterFee == requests[_requestId].amount, "Incorrect amount provided");

        requests[_requestId].isFulfilled = true;
        providers[_requestId] = LiquidityProvider({
            provider: msg.sender,
            amountProvided: amountAfterFee
        });

        // Transfer the fee to the owner
        payable(owner).transfer(fee);

        // Transfer the funds to the requester minus the fee
        payable(requests[_requestId].requester).transfer(amountAfterFee);

        emit RequestFulfilled(_requestId, msg.sender, amountAfterFee);
    }

    // Allows SMEs to pay the monthly insurance fee in USDC
    function payMonthlyInsuranceFee() external {
        stableCoin.transferFrom(msg.sender, owner, monthlyInsuranceFee);
        lastInsurancePayment[msg.sender] = block.timestamp;
    }

    // Functionality for withdrawal and other contract management can be added here
}
