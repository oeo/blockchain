# @done
- sha256 memory blockchain
- scaling proof of work
  - automatic difficulty adjustments
  - cumulative difficulty preference over chain length
- rest server
- websocket p2p syncing
  - concensus difficulty

# @todo
- keypairs + accounts
- transactions (ledger/memos)
- automatic peer discovery
- redis persistence
- chain/account explorer
- wallet

### optimizations
- websocket p2p sync
  - allow transport of partial chain instead of entire chain during sync
    - chain offset query support

