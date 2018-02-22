# @done
- sha256 memory blockchain
- scaling proof of work
  - automatic difficulty adjustments
  - cumulative difficulty preference over chain length
- node http rest server
- websocket p2p sync
  - concensus difficulty
- keypairs/accounts/wallets
- static block reward
- transactions base

# @todo
- transaction mempool + p2p sync
- transaction fees
- dynamic block reward
- p2p discovery
  - https://ethereum.stackexchange.com/questions/7743/what-are-the-peer-discovery-mechanisms-involved-in-ethereum
- chain persistence (redis)
- chain explorer
- web wallet
- cli mining script/bin

## @later
- refactor native entities into mongoose models
  - transaction, transaction output
  - address
- allow transport of partial chain over websocket
  - chain offset query support in p2p to minimize data in the pipe

## @future
- anonymous transactions
  - utilize static wallet and implement redeemables or masternodes to obfuscate origin
  - don't have to nessessarily be the most convenient
- modify address algo for shorter addresses (currently using `secp256k1`)
- cluster support
  - websocket complications
- docker wrap

