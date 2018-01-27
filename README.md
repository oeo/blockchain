# @done
- sha256 in-memory blockchain
- rest server
- websocket p2p syncing

# @todo
- redis persistence
- keypairs/accounts
- transactions (ledger/memos)
- peer discovery
- blockchain explorer
- wallet

### optimizations
- websocket p2p sync
  - websocket send entire chain to peer only (instead of broadcast)
  - allow transport of partial chain instead of entire chain during sync
    - chain offset query support

