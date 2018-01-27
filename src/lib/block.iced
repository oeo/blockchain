_ = require('wegweg')({
  globals: on
})

mongoose = require 'mongoose'

hash = require './hash'

# entity
Schema = new mongoose.Schema({

  index: Number
  ctime: Number

  hash: String
  prev_hash: String

  data: [
    mongoose.Schema.Types.Mixed
  ]

},{_id:false})

# calc hash on create
Schema.path('index').set((x)->
  @hash ?= hash.sha256([
    @index
    @ctime
    @prev_hash
    JSON.stringify(@data)
  ].join(''))

  return x
)

# methods
Schema.methods.is_valid_structure = (->
  props = {
    index: 'number'
    ctime: 'number'
    hash: 'string'
    prev_hash: 'string'
    data: 'object'
  }

  for k,v of props
    return false if !this[k]
    return false if typeof this[k] isnt v

  return true
)

# statics
Schema.statics.calculate_hash = ((block_obj) ->
  return hash.sha256([
    block_obj.index
    block_obj.ctime
    block_obj.prev_hash
    JSON.stringify(block_obj.data)
  ].join(''))
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
    prev_hash: 'abc'
    data: []
  })

  log /valid block/, b
  log b.is_valid_structure()

  b2 = new Block({
    index: 'a'
  })

  log /invalid block/, b2
  log b.is_valid_structure()

  exit 0

