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
  @get_id: ((t) ->
    inputs_str = (_.map t.inputs, (input) ->
      return input.output_id + input.output_index
    ).join('')
    outputs_str = (_.map t.outputs, (output) ->
      return output.address + output.amount
    ).join('')
    return hash.sha256(inputs_str + outputs_str)
  )

  @sign_

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

  log /id/, Transaction.get_id(t)

  log t
  exit 0

