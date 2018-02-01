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

module.exports = txns = {}

###
transaction = {
  id: null
  from: null
  signature: null
  outputs: [{
    address:
    amount: 0
  }]
}
###

txns.get_id = ((transaction,cb) ->
  bulk = transaction.from

  for item in transaction.outputs
    bulk += item.address
    bulk += item.amount

  return cb null, hash.sha256(bulk)
)

txns.get_signature = ((transaction,priv,cb) ->
  signed = addresses.sign transaction.id, priv
  return cb null, signed
)

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
    for x in ['address','amount']
      return cb new Error "`output.#{x}` required" if !item[x]

  transaction = {
    id: null
    from: opt.from
    signature: null
    outputs: opt.outputs
  }

  await @get_id transaction, defer e,transaction.id
  if e then return cb e

  await @get_signature transaction, opt.priv, defer e,transaction.signature
  if e then return cb e

  return cb null, transaction
)

txns.validate = ((transaction,cb) ->
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

  ###
  t = new Transaction({
    id: 'hello'
  })

  await Transaction.validate t, defer e,valid
  log e
  log valid
  ###

  exit 0

