if !module.parent
  global.CONFIG = (require('dotenv').config({
    path: __dirname + '/../../config'
  })).parsed

_ = require('wegweg')({
  globals: on
})

elliptic = require 'elliptic'
curve = new elliptic.ec('curve25519')

addresses = require './addresses'
hash = require './hash'

###
Output {
  address: null
  amount: 0
}
Transaction {
  id: null
  input: {
    address: null
    signature: null
  }
  outputs: []
}
###

module.exports = txns = {}

txn._template = {
  id: null
  input: {
    address: null
    signature: null
  }
  outputs: []
}

txns.get_id = ((transaction,cb) ->
  return cb null, hash
)

txns.get_signature = ((transaction,prv,cb) ->
  await addresses.sign transaction.id, prv, defer e,signature
  if e then return cb e

  return cb null, signature
)

## test
if !module.parent

  log /TEST/

  ###
  t = new Transaction({
    id: 'hello'
  })

  await Transaction.validate t, defer e,valid
  log e
  log valid
  ###

  exit 0

