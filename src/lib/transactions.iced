if !module.parent
  global.CONFIG = (require('dotenv').config({
    path: __dirname + '/../../config'
  })).parsed

_ = require('wegweg')({
  globals: on
})

elliptic = require 'elliptic'
curve = new elliptic.ec('curve25519')

blockchain = require './blockchain'
addresses = require './addresses'
hash = require './hash'

COINBASE_AMOUNT = 1000

class Input
  output_id: null
  output_index: null
  signature: null
  constructor: ((opt) ->
    for k,v of opt
      if this[k]? then this[k] = v
    return @
  )

class Output
  address: null
  amount: 0
  constructor: ((opt) ->
    for k,v of opt
      if this[k]? then this[k] = v
    return @
  )

class UnspentOutput
  output_id: null
  output_index: null
  address: null
  amount: 0
  constructor: ((opt) ->
    for k,v of opt
      if this[k]? then this[k] = v
    return @
  )

class Transaction
  id: null
  inputs: []
  outputs: []

  constructor: ((opt) ->
    for k,v of opt
      if this[k]? then this[k] = v
    return @
  )

  # hash the inputs and outputs to create a transaction id
  @calculate_id: ((txn) ->
    inputs_str = (_.map txn.inputs, (input) ->
      return input.output_id + input.output_index
    ).join('')

    outputs_str = (_.map txn.outputs, (output) ->
      return output.address + output.amount
    ).join('')

    return hash.sha256(inputs_str + outputs_str)
  )

  @sign_input: ((txn,input_index,priv,cb) ->
    await blockchain.get_unspent_outputs defer e,unspent_outputs
    if e then return cb e

    data_to_sign = txn.id
    input = txn.inputs[input_index]


    #
    return cb null, true
  )

  # validate a transaction
  @validate: ((txn,cb) ->

    # validate id hash
    if Transaction.calculate_id(txn) isnt txn.id
      log new Error 'Invalid transaction (`id`)'
      return cb null, false

    # k, fine.
    return cb null, true
  )

##
module.exports = txns = {
  Input
  Output
  UnspentOutput
  Transaction
}

## test
if !module.parent

  log /TEST/

  t = new Transaction({
    id: 'hello'
  })

  await Transaction.validate t, defer e,valid
  log e
  log valid

  log t
  exit 0

