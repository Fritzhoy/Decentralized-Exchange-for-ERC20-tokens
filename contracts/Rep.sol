pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20";
contract Rep is ERC20 {
  constructor() ERC20("REP", "Augur Token") {}

}