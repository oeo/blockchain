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

###
transaction = {
  id: null
  input: {
    address: null
    signature: null
  }
  outputs: [{
    address:
    amount: 0
  }]
}
###

txns.get_id = ((transaction,cb) ->
  return cb null, hash
)

txns.get_signature = ((transaction,priv,cb) ->
  signed = addresses.sign transaction.id, priv
  return cb null, signed
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

