if !module.parent
  global.CONFIG = (require('dotenv').config({
    path: __dirname + '/../../config'
  })).parsed

_ = require('wegweg')({
  globals: on
})

Block = require './block'
hash = require './hash'

GENESIS = {
  index: 0
  ctime: 1517012327
  hash: hash.auto(env.GENESIS_HASH_STRING)
  data: env.GENESIS_HASH_STRING
}

blockchain = {

  # primary chain
  blocks: [
    new Block(GENESIS)
  ]

  # unspent transaction outputs
  unspent_outputs: []
}

# blocks
## @todo: redis persistence
blockchain.get_blockchain = ((cb) ->
  return cb null, @blocks
)

blockchain.set_blockchain = ((chain,cb) ->
  @blocks = chain
  require('./peers').broadcast_last_block()

  return cb null, true
)

blockchain.get_block = ((index_or_hash,cb) ->
  if !(block = _.find(@blocks,{index:(+index_or_hash)}))
    block = _.find(@blocks,{hash:index_or_hash})

  return cb null, block
)

blockchain.get_last_block = ((cb) ->
  return cb null, _.last(@blocks)
)

blockchain.add_block = ((block,cb) ->
  await @is_valid_next_block block, null, defer e,valid
  if e then return cb e

  if !valid
    return cb new Error 'Block is invalid'

  # @todo: distribute block reward

  @blocks.push new Block(block)
  require('./peers').broadcast_last_block()

  return cb null, true
)

blockchain.replace_chain = ((new_chain,cb) ->
  await @is_valid_chain new_chain, defer e,valid
  if e then return cb e

  if !valid
    return cb new Error 'Received an invalid chain, refusing to `replace_chain`'

  # check if the chain has a heavier weight than us
  await blockchain.calculate_difficulty_weight null, defer e,our_weight
  if e then return cb e

  await blockchain.calculate_difficulty_weight new_chain, defer e,their_weight
  if e then return cb e

  if their_weight > our_weight
    log 'Replacing our blockchain with a larger chain'

    await @set_blockchain new_chain, defer e
    if e then return cb e

  return cb null, true
)

# unspent outputs
## @todo: redis persistence
blockchain.get_unspent_outputs = ((cb) ->
  return cb null, @unspent_outputs
)

blockchain.find_unspent_output = ((opt,cb) ->
  return cb null, _.find(@unspent_outputs,opt)
)


##
blockchain.is_valid_next_block = ((block,prev_block,cb) ->
  if !Block.is_valid_schema(block)
    log new Error 'Invalid block (schema)'
    return cb null, false

  # validate provided difficulty against hash difficulty
  binary = hash._hex_to_binary(block.hash)

  calculated_hash_difficulty = (do =>
    i = 0
    for item in binary.split('')
      if item in ['0',0]
        i += 1; continue
      break
    return i
  )

  if block.difficulty > calculated_hash_difficulty
    log new Error 'Invalid block (`difficulty` is greater than calculated hash difficulty)'

  if !prev_block
    await @get_last_block defer e,prev_block
    if e then return cb e

    # validate difficulty on the new block
    await @get_difficulty defer e,difficulty
    if e then return cb e

    if block.difficulty isnt difficulty
      log new Error 'Invalid block (`difficulty`)'
      return cb null, false

  # validate index
  if block.index isnt (prev_block.index + 1)
    log new Error 'Invalid block (`index`)'
    return cb null, false

  # validate prev
  if block.prev isnt prev_block.hash
    log new Error 'Invalid block (`prev`)'
    return cb null, false

  # validate hash
  if block.hash isnt (calced_hash = Block.calculate_hash(block))
    log new Error 'Invalid block (`hash`)'
    return cb null, false

  # validate pow
  if !Block.is_valid_proof(block)
    log new Error 'Invalid block (`proof`)'
    return cb null, false

  # validate ctime
  if block.ctime < (prev_block.ctime - 60)
    log new Error 'Invalid block (`ctime` before previous block)'
    return cb null, false
  if block.ctime > (_.time() + 60)
    log new Error 'Invalid block (`ctime` too far in the future)'
    return cb null, false

  # k, fine.
  return cb null, true
)

# validate a chain (starting at the genesis block)
blockchain.is_valid_chain = ((chain,cb) ->

  # validate genesis block
  chain_genesis = chain[0]

  for key in ['index','hash','ctime']
    if chain_genesis[key] isnt GENESIS[key]
      log new Error 'Invalid genesis block'
      return cb null, false

  # iterate the chain
  i = 0; for block in chain
    if i is 0
      i += 1
      continue

    await @is_valid_next_block block, chain[i - 1], defer e,valid
    if e then return cb e

    if !valid
      log new Error 'Invalid block in chain', block.index
      return cb null, false
    else
      i += 1

  return cb null, true
)

##
blockchain.generate_next_block = ((data,cb) ->
  await @get_last_block defer e,last
  if e then return cb e

  await @get_difficulty defer e,difficulty
  if e then return cb e

  block_base = {
    index: (last.index + 1)
    ctime: _.time()

    prev: last.hash

    difficulty: difficulty

    data: data
  }

  await blockchain.mine_block block_base, defer e,block
  if e then return cb e

  return cb null, block
)

blockchain.mine_block = ((block,cb) ->
  block.proof ?= 0
  block.hash = Block.calculate_hash(block)

  while 1
    block.hash = Block.calculate_hash(block)

    if Block.is_valid_proof(block)
      return cb null, block
    else
      block.proof += 1

  return cb null, false
)

blockchain.get_difficulty = ((cb) ->
  await @get_last_block defer e,last
  if e then return cb e

  difficulty = +(last.difficulty ? env.DIFFICULTY_LEVEL_START)

  # adjust difficulty based on last block's solve-time
  if (last.index % env.DIFFICULTY_INCREASE_INTERVAL_BLOCKS is 0) and last.index isnt 0
    last_adjustment_index = (last.index + 1 - (+env.DIFFICULTY_INCREASE_INTERVAL_BLOCKS))

    await @get_block last_adjustment_index, defer e,last_adjustment_block
    if e then return cb e

    return cb null, difficulty if !last_adjustment_block

    difficulty = last_adjustment_block.difficulty

    secs_expected = (+env.DIFFICULTY_INCREASE_INTERVAL_BLOCKS * +env.DIFFICULTY_SOLVE_INTERVAL_SECS)
    secs_elapsed = (last.ctime - last_adjustment_block.ctime)

    # too fast, increase difficulty
    if secs_elapsed < (secs_expected / 2)
      difficulty += 1

    # too slow, decrease difficulty
    else if secs_elapsed > (secs_expected * 2)
      difficulty -= 1

  return cb null, difficulty
)

blockchain.calculate_difficulty_weight = ((blocks=null,cb) ->
  if !blocks
    await @get_blockchain defer e,blocks
    if e then return cb e

  weight = 0

  for block in blocks
    weight += Math.pow(2,(block.difficulty ? 0))

  return cb null, weight
)

##
module.exports = blockchain

## test
if !module.parent
  log /TEST/

  await blockchain.generate_next_block 'Hello', defer e,next_block
  if e then throw e

  log /next_block/, next_block

  exit 0

