// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CarbonCreditTrading {
    struct Trade {
        address seller;
        address buyer;
        uint256 amount; // Number of carbon credits
        uint256 price; // Price per credit in wei
        uint256 timestamp;
        bool completed;
    }

    mapping(address => uint256) public balances; // Carbon credit balances of businesses
    Trade[] public trades;
    address public admin;

    event TradeCreated(
        uint256 tradeId,
        address indexed seller,
        uint256 amount,
        uint256 price,
        uint256 timestamp
    );
    event TradeCompleted(
        uint256 tradeId,
        address indexed buyer,
        uint256 amount,
        uint256 totalPrice,
        uint256 timestamp
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier hasSufficientCredits(address seller, uint256 amount) {
        require(balances[seller] >= amount, "Insufficient carbon credits");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function depositCredits(address _business, uint256 _amount) public onlyAdmin {
        require(_amount > 0, "Amount must be greater than zero");
        balances[_business] += _amount;
    }

    function createTrade(uint256 _amount, uint256 _price) public hasSufficientCredits(msg.sender, _amount) {
        require(_amount > 0, "Amount must be greater than zero");
        require(_price > 0, "Price must be greater than zero");

        balances[msg.sender] -= _amount;
        trades.push(Trade({
            seller: msg.sender,
            buyer: address(0),
            amount: _amount,
            price: _price,
            timestamp: block.timestamp,
            completed: false
        }));

        emit TradeCreated(trades.length - 1, msg.sender, _amount, _price, block.timestamp);
    }

    function buyCredits(uint256 _tradeId) public payable {
        require(_tradeId < trades.length, "Invalid trade ID");
        Trade storage trade = trades[_tradeId];
        require(!trade.completed, "Trade already completed");
        require(msg.value == trade.amount * trade.price, "Incorrect payment amount");

        trade.buyer = msg.sender;
        trade.completed = true;
        balances[msg.sender] += trade.amount;
        payable(trade.seller).transfer(msg.value);

        emit TradeCompleted(_tradeId, msg.sender, trade.amount, msg.value, block.timestamp);
    }

    function getTradeDetails(uint256 _tradeId) public view returns (Trade memory) {
        require(_tradeId < trades.length, "Invalid trade ID");
        return trades[_tradeId];
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}
