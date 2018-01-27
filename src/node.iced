_ = require('wegweg')({
  globals: on
})

hash = require './lib/hash'

Block = require './lib/block'

GENESIS = new Block({
  id: 0

  hash: hash.sha256('helo@jolt')
  prev_hash: null

  ctime: 1517011414


})

log "rdy@#{new Date}"

