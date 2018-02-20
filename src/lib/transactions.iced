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

# primary export
module.exports = txns = {

  # unconfirmed transactions
  pool: []
}

txns.get_id = ((transaction,cb) ->
  bulk = transaction.from
  bulk += transaction.last_output_block

  for item in transaction.outputs
    bulk += item.to
    bulk += item.amount

  return cb null, hash.sha256(bulk)
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
    for x in ['to','amount']
      return cb new Error "`output.#{x}` required" if !item[x]

  transaction = {
    id: null
    from: opt.from
    last_output_block: null
    signature: null
    outputs: opt.outputs
  }

  # add last output block index
  blockchain = require __dirname + '/blockchain'

  await blockchain.get_balance opt.from, defer e,balance
  if e then return cb

  transaction.last_output_block = (balance?.last_output_block ? null)

  # hash the block and sign it
  await @get_id transaction, defer e,transaction.id
  if e then return cb e

  # generate signature
  await @get_signature transaction, opt.priv, defer e,transaction.signature
  if e then return cb e

  return cb null, transaction
)

# validate given transaction object
txns.validate = ((transaction,cb) ->
  required = [
    'id'
    'from'
    'signature'
    'outputs'
  ]

  for x in required
    return cb new Error "Invalid transaction (`#{x}` required)" if !transaction[x]

  transaction.last_output_block ?= null

  if !transaction.outputs?.length
    return cb new Error 'Invalid transaction (no outputs)'

  if _.type(transaction.outputs) isnt 'array'
    transaction.outputs = [transaction.outputs]

  total_out = 0

  for item in transaction.outputs
    for x in ['to','amount']
      return cb new Error "`output.#{x}` required" if !item[x]

    total_out += (+item.amount)

  # check available balance
  blockchain = require __dirname + '/blockchain'

  await blockchain.get_balance transaction.from, defer e,balance
  if e then return cb e

  if !balance or (balance?.amount < total_out)
    return cb new Error 'Invalid transaction (output total exceeds balance)'

  # validate last output block index
  if balance?.last_output_block isnt transaction.last_output_block
    return cb new Error 'Invalid transaction (`last_output_block`)'

  # validate hash
  await @get_id transaction, defer e,calculated_tid
  if e then return cb e

  if transaction.id isnt calculated_tid
    return cb new Error 'Invalid transaction (`id`)'

  # validate signature
  await @verify_signature transaction, defer e,valid
  if e then return cb e

  if !valid
    return cb new Error 'Invalid transaction (`signature`)'

  # txn is fine
  return cb null, true
)

## test
if !module.parent

  log /TEST/

  txn_opt = {
    from: addresses.TEST_ADDRESSES.DAN.pub
    priv: addresses.TEST_ADDRESSES.DAN.priv
    outputs: [{
      to: addresses.TEST_ADDRESSES.BOB.pub
      amount: 5
    }]
  }

  await txns.create txn_opt, defer e,transaction
  if e then throw e

  log /transaction/
  log transaction

  exit 0

