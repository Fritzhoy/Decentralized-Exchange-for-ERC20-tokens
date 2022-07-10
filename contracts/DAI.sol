pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20";
contract DAI is ERC20 {

  constructor() ERC20("DAI", "Dai Stablecoin") {}

}