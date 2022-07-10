pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable";
import "@openzeppelin/contracts/token/IERC20";

contract Dex is Ownable {
  struct Token {
    bytes32 ticker;
    address tokenAddress;
  }

  mapping(bytes32 => Token) public tokens;
  // list all the tokens
  bytes32[] public tokenList;

  //tracks how many tokens were send by which address 
  mapping(address => mapping(bytes32 => uint)) public traderBalances;
  address public admin;

  constructor() {
    onwer = msg.sender;

  }

  function addtoken(bytes32 ticker, address tokenAddress) external onlyOwner {
    tokens[ticker] = Token(ticker, tokenAddress);
    tokenList.push(ticker);
  }


  function deposit(uint amount, bytes32 ticker) external tokenExist(ticker){
    IERC20(tokens[ticker].tokenAddress).transferFrom(
      msg.sender,
      address(this),
      amount
      );
      traderBalances[msg.sender][ticker] += amount;
  }

  function withdraw(uint amount, bytes32 ticker) external tokenExist(ticker) {
    require(traderBlanaces[msg.sender][ticker] >= amount, "amount too low");
    traderBalances[msg.sender][ticker] -= amount;
    IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
  }

  modifier tokenExist(bytes32 ticker) {
    require(token[ticker].tokenAddress != address(0), "this token does not exist");
    _;
  }

}