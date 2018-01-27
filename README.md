# @done
- sha256 blockchain
- scaling proof of work
  - automatic difficulty adjustments
  - concensus difficulty
- rest server
- websocket p2p syncing
  - cumulative difficulty preference (vs just chain length)

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

