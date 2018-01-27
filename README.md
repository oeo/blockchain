# @done
- sha256 in-memory blockchain
- scaling proof of work
  - automatic difficulty adjustments
  - concensus difficulty
  - cumulative difficulty preference instead of chain length
- rest server
- websocket p2p syncing

# @todo
- proof of work
- keypairs/accounts
- transactions (ledger/memos)
- automatic peer discovery
- redis persistence
- blockchain explorer
- wallet

### optimizations
- websocket p2p sync
  - allow transport of partial chain instead of entire chain during sync
    - chain offset query support

