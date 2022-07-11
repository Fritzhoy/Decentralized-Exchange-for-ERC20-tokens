// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable";
import "@openzeppelin/contracts/token/IERC20";

contract Dex is Ownable {
    //Limit-Order
    enum Side {
        BUY,
        SELL
    }

    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }

    //Struct to represent each limit order
    struct Order {
        uint256 id;
        address trader;
        Side side;
        bytes32 ticker; //ticker of the token
        uint256 amount;
        uint256 filled; //how much of the order has been filled
    }

    mapping(bytes32 => Token) public tokens;
    // list all the tokens
    bytes32[] public tokenList;
    /*OrderBook,
     **nest mapping: uint represent the Side 0: BUY 1: SELL
     ** @array: Order will be a array will sort by price highest price.
     ** if the order have the same price, it will be sort by the oldest one.
     **/
    mapping(bytes32 => mapping(uint256 => Order[])) orderBook;

    //tracks how many tokens were send by which address
    mapping(address => mapping(bytes32 => uint256)) public traderBalances;
    address public owner;
    uint256 public nextOrderId;
    uint256 public nextTradeId;
    bytes32 constant DAI = bytes32("DAI");

    event NewTrader(
        uint256 tradeId,
        uint256 orderId,
        bytes32 indexed ticker,
        address indexed trader1,
        address indexed trader2,
        uint256 amount,
        uint256 price,
        uint256 date
    );

    constructor() {
        owner = msg.sender;
    }

    function addtoken(bytes32 ticker, address tokenAddress) external onlyOwner {
        tokens[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);
    }

    function deposit(uint256 amount, bytes32 ticker)
        external
        tokenExist(ticker)
    {
        IERC20(tokens[ticker].tokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        traderBalances[msg.sender][ticker] += amount;
    }

    function withdraw(uint256 amount, bytes32 ticker)
        external
        tokenExist(ticker)
    {
        require(traderBlanaces[msg.sender][ticker] >= amount, "amount too low");
        traderBalances[msg.sender][ticker] -= amount;
        IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
    }

    function createLimitOrder(
        bytes32 ticker,
        uint256 amount,
        uint256 price,
        Side side
    ) external tokenExist(ticker) tokenIsNotDai(ticker) {
        if (side == Side.SELL) {
            require(
                traderBaknces[msg.sender][ticker] >= amount,
                "token balance too low"
            );
        } else {
            require(
                traderBalances[msg.sender][DAI] >= amount * price,
                "dai balance to low"
            );
        }
        Order[] storage orders = orderbook[ticker][uint256(side)];
        orders.push(
            Order(nextOrderId, msg.sender, side, ticker, amount, 0, price, now)
        );
        //Bublle sort - highest price to lowest price orders
        uint256 i = order.length - 1;
        while (i > 0) {
            if (side == side.BUY && order[i - 1].price > orders[i].price) {
                break;
            }
            if (side == side.SELL && order[i - 1].price < orders[i].price) {
                break;
            }
            Order memory order = orders[i - 1];
            orders[i - 1] = orders[i];
            orders[i] = order;
            i--;
        }
        nextOrderId++;
    }

    function createMarketOrder(
        bytes32 ticker,
        uint256 amount,
        Side side
    ) external tokenExist(ticker) tokenIsNotDai(ticker) {
        if (side == Side.SELL) {
            require(
                traderBaknces[msg.sender][ticker] >= amount,
                "token balance too low"
            );
        }
        Order[] storage orders = orderBook[ticker][
            uint256(side == Side.BUY ? Side.SELL : Side.BUY)
        ];
        uint256 i;
        uint256 remaining = amount;
        while (i < order.length && remaining > 0) {
            uint256 avaiable = order[i].amount - orders[i].filled;
            uint256 matched = (remaining > available) ? available : remaining;
            remaining -= matched;
            orders[i].filled += matched;
            emit NewTrader(
                nextTradeId,
                orders[i].id,
                ticker,
                order[i].trader,
                msg.sender,
                matched,
                orders[i].price,
                now
            );
            if (side == Side.SELL) {
                traderBalances[msg.sender][ticker] -= matched;
                traderBalances[msg.sender][DAI] += matched * orders[i].price;
                traderBalances[orders[i].trader] += matched;
                traderBalances[orders[i].tarder][DAI] -= matched *orders[i].price;
            }
            if (side == Side.BUY) {
                traderBalances[msg.sender][ticker] += matched;
                traderBalances[msg.sender][DAI] -= matched * orders[i].price;
                traderBalances[orders[i].trader] -= matched;
                traderBalances[orders[i].tarder][DAI] += matched *orders[i].price;
            }
            nextTradeId++;
            i++; 
        }
    }

    modifier tokenIsNotDai(bytes32 ticker) {
        require(ticker != DAI, "cannot trade DAI");
        _;
    }
    modifier tokenExist(bytes32 ticker) {
        require(
            token[ticker].tokenAddress != address(0),
            "this token does not exist"
        );
        _;
    }
}
