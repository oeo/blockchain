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
- txn mempool w/ p2p sync
  - block generation
- txn fees
- block reward
- p2p discovery/bootstrap nodes
- redis chain persistence
- chain explorer/web wallet
- node mining flag
- standalone mining script

## @later
- convert native entities into mongoose models
  - transaction, transaction output
  - address
- allow transport of partial chain over websocket
  - chain offset query support in p2p to minimize data in the pipe
- anonymous transactions
  - utilize static wallet and implement redeemables or masternodes to obfuscate origin
  - don't have to nessessarily be the most convenient
- modify address algo for shorter addresses (currently using `secp256k1`)
- cluster support
  - websocket complications
- docker wrap

---

```
5. Network
The steps to run the network are as follows:
1) New transactions are broadcast to all nodes.
2) Each node collects new transactions into a block.
3) Each node works on finding a difficult proof-of-work for its block.
4) When a node finds a proof-of-work, it broadcasts the block to all nodes.
5) Nodes accept the block only if all transactions in it are valid and not already spent.
6) Nodes express their acceptance of the block by working on creating the next block in the
chain, using the hash of the accepted block as the previous hash.
```

```
With the possibility of reversal, the need for trust spreads.
```



