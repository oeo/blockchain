if !module.parent
  global.CONFIG = (require('dotenv').config({
    path: __dirname + '/../../config'
  })).parsed

_ = require('wegweg')({
  globals: on
})

elliptic = require 'elliptic'
curve = (new elliptic.ec 'curve25519')

addresses = require './addresses'
hash = require './hash'

###
Output {
  address: null
  amount: 0
}
Transaction {
  id: null
  from: null
  signature: null
  outputs: []
}
###

###
transaction = {
  id: null
  from: null
  last_input_block: null
  last_output_block: null
  signature: null
  outputs: [{
    address:
    amount: 0
  }]
}
###

module.exports = txns = {}

txns.get_id = ((transaction,cb) ->
  bulk = transaction.from
  bulk += transaction.last_input_block
  bulk += transaction.last_output_block

  for item in transaction.outputs
    bulk += item.address
    bulk += item.amount

  return cb null, hash.sha256(bulk)
)

txns.get_last_transaction_blocks = ((pub,cb) ->
  blockchain = require __dirname + '/blockchain'

  await blockchain.get_balances defer e,balances
  if e then return next e

  return cb null, {
    last_input_block: (balances[pub]?.last_input_block ? null)
    last_output_block: (balances[pub]?.last_output_block ? null)
  }
)

txns.get_signature = ((transaction,priv,cb) ->
  signed = addresses.sign transaction.id, priv
  return cb null, signed
)

txns.verify_signature = ((transaction,cb) ->
  valid = addresses.verify transaction.id, transaction.signature, transaction.from
  return cb null, valid
)

# generate new transaction
txns.create = ((opt,cb) ->
  blockchain = require __dirname + '/blockchain'

  required = [
    'from'
    'priv'
    'outputs'
  ]

  for x in required
    return cb new Error "`#{x}` required" if !opt[x]

  if !opt.outputs?.length
    return cb new Error 'Transaction has no outputs'

  for item in opt.outputs
    for x in ['address','amount']
      return cb new Error "`output.#{x}` required" if !item[x]

  transaction = {
    id: null
    from: opt.from
    last_input_block: null
    last_output_block: null
    signature: null
    outputs: opt.outputs
  }

  # add last input/output blocks
  await @get_last_transaction_blocks opt.from, defer e,last_blocks
  if e then return cb e

  transaction.last_input_block = last_blocks.last_input_block
  transaction.last_output_block = last_blocks.last_output_block

  # hash the block and sign it
  await @get_id transaction, defer e,transaction.id
  if e then return cb e

  await @get_signature transaction, opt.priv, defer e,transaction.signature
  if e then return cb e

  return cb null, transaction
)

txns.validate = ((transaction,cb) ->
  blockchain = require __dirname + '/blockchain'

  required = [
    'id'
    'from'
    'last_input_block'
    'last_output_block'
    'signature'
    'outputs'
  ]

  for x in required
    return cb new Error "Invalid transaction (`#{x}` required)" if !opt[x]?

  if !opt.outputs?.length
    return cb new Error 'Invalid transaction (no outputs)'

  if _.type(opt.outputs) isnt 'array'
    opt.outputs = [opt.outputs]

  total_out = 0

  for item in opt.outputs
    for x in ['address','amount']
      return cb new Error "`output.#{x}` required" if !item[x]

    total_out += (+item.amount)

  # check available balance
  await blockchain.get_balance transaction.from, defer e,balance
  if e then return cb e

  if !balance
    return cb new Error 'Invalid transaction (balance not found)'

  if balance?.amount < total_out
    return cb new Error 'Invalid transaction (output total exceeds balance)'

  # check last balance input/output blocks
  if balance?.last_input_block isnt transaction.last_input_block
    return cb new Error 'Invalid transaction (`last_input_block`)'

  if balance?.last_output_block isnt transaction.last_output_block
    return cb new Error 'Invalid transaction (`last_output_block`)'

  # id hash
  await @get_id transaction, defer e,calculated_tid
  if e then return cb e

  if transaction.id isnt calculated_tid
    return cb new Error 'Invalid transaction (`id`)'

  # id signature
  await @verify_signature transaction, defer e,valid
  if e then return cb e

  if !valid
    return cb new Error 'Invalid transaction (`signature`)'

  # fine.
  return cb null, true
)

## test
if !module.parent

  log /TEST/

  txn_opt = {
    from: addresses.TEST_ADDRESSES.DAN.pub
    priv: addresses.TEST_ADDRESSES.DAN.priv
    outputs: [{
      address: addresses.TEST_ADDRESSES.BOB.pub
      amount: 5
    }]
  }

  await txns.create txn_opt, defer e,transaction
  if e then throw e

  log /transaction/
  log transaction

  exit 0

