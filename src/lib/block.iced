_ = require('wegweg')({
  globals: on
})

mongoose = require 'mongoose'

hash = require './hash'

# entity
Schema = new mongoose.Schema({

  index: Number
  ctime: Number

  # hash
  hash: String
  prev: String

  # pow
  difficulty: {
    type: Number
    default: env.DIFFICULTY_LEVEL_START
  }

  proof: {
    type: Number
    default: 0
  }

  # txns
  data: {
    type: mongoose.Schema.Types.Mixed
    default: null
  }

},{_id:false})

###
block = {
  index: 0
  ctime: 0

  hash: null
  prev: null

  difficulty: 5
  proof: null

  data: {
    transactions: [transaction]
  }
}
###

# statics
Schema.statics.is_valid_schema = ((block_obj) ->
  props = {
    index: 'number'
    ctime: 'number'

    hash: 'string'
    prev: 'string'

    difficulty: 'number'
    proof: 'number'

    data: 'object'
  }

  # ignore `prev` on the genesis block
  if block_obj.index is 0 and block_obj.hash is hash.auto(env.GENESIS_HASH_STRING)
    for key in [
      'prev'
      'data'
    ]
      delete props[key]

  for k,v of props
    return false if !block_obj[k]?
    if v
      return false if typeof block_obj[k] isnt v

  return true
)

# validate proof of work
Schema.statics.is_valid_proof = is_valid_proof = ((block_obj) ->
  str = ''
  str += '0' for x in [1..block_obj.difficulty]

  binary = hash._hex_to_binary(block_obj.hash)
  return true if binary.startsWith(str)

  return false
)

# calculate block hash
Schema.statics.calculate_hash = calculate_hash = ((block_obj) ->
  arr = [
    block_obj.index
    block_obj.ctime

    (block_obj.prev ? null)

    block_obj.difficulty
    block_obj.proof

    JSON.stringify(block_obj.data ? {})
  ]

  return hash.sha256(arr.join(''))
)

##
module.exports = Block = mongoose.model 'Block', Schema

## test
if !module.parent
  log /TEST/

  b = new Block({
    index: 3
    ctime: 1517012327
    hash: hash.sha256('helo')
    prev: 'abc'
    data: []
  })

  log /valid block/, b
  log /is_valid_structure/, b.is_valid_structure()

  b2 = new Block({
    index: 'a'
  })

  log /invalid block/, b2
  log /is_valid_structure/, b.is_valid_structure()

  exit 0

