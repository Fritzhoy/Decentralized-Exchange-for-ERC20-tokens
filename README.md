# Decentralized-Exchange-for-ERC20-tokens

Decentralized Exchange to trade ERC20 tokens.


## Architecture

### User Wallet
### FrontEnd (Web)
### Smart Contract (Blockchain)

## Trade sequence

1 - User A sends ether to the DEX smart contract
2 - User A creates a buy limit order and send it to the Dex smart contract
3- User B send the token ABC to the DEX smart contract
4 - User B creates the sell offer and send it to the DEX smart contract
5 - Smart contract matches user A & B, and carry out the trade.
6 - User A withdraw your ABC token
7 - User B withdraw your ethers

## Order Types

1) Limit Order: specify max/min limit price
2) Market Order, agree to whatever price is on the Market

### Order Fields:
 
- Currency
- Amount
- Types

## Orderbook

- List all limit orders
- Matches incoming market orders against limit orders
- Remove limit orders that were executed

Orderbooks follow a price-time algorithm. 

When an incoming market order arrive, the orderbook will try to match it with the market order that has the best price. If several limit orders have the same price, the one that was created first get matched in priority.

if the amount of market and limit order dont match?

in this case, we have two possibilities:

- Case 1: Amount of market order < amount of limit order.
In this case the market order will be fully executed, but the limit order will only be partially executed, the non executed part remain in the order book.

to make the Dex simple, you can disallow limit orders that "cross the books"

- case 2: Amount of market order > amount of limit order. for example a buy order with a limit price so high that it would be matched instantly against limit sell orders on the other side of the orderbook.

In this case the limit order will be fully executed, and the orderbook will continue to try to match the remain market order with other limit order.

There is also the possibility that there is not enough liquidity to match the remain market order, one way to avoid this behavior is disallow parcial matching of market order by rejecting any market order that can't be matched entirely. 

## Settlement

After the trade, the 2 users will have to use the withdraw function of the wallet of the DEX smart contract to get back their asset.

Note: the transfer only take place symbolically. All the trade asset are hel in the wallet of the DEX smart contract at the moment of the trade.

To settle the transfers, the internal ledger of the DEX needs to be update to reflect the asset transfer. 