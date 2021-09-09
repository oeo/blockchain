# @todo
- [x] create standalone mining script
- [ ] deflationary block reward
- [ ] transaction fees
- [ ] enforce block size limit
- [ ] persist: leveldb for chain, redis general storage
- [ ] p2p node discovery
- [ ] p2p mempool

# @done
- [x] sha256 blockchain
- [x] scaling proof of work
  - automatic difficulty adjustments
  - cumulative difficulty preference over chain length
- [x] http rest server
- [x] websocket p2p sync
  - concensus difficulty
- [x] keypairs/wallets
- [x] static block reward
- [x] transactions base

## @later
- convert native entities into mongoose models
  - transaction, transaction output
  - address
- allow transport of partial chain over websocket
  - merkle tree provides an index
  - block height offset query support to minimize data in the pipe
- modify address algo for shorter addresses
- web wallet
- chain explorer

## @eventual
- remove + internalize all deps
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



