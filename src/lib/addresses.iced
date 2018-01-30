if !module.parent
  global.CONFIG = (require('dotenv').config({
    path: __dirname + '/../../config'
  })).parsed

_ = require('wegweg')({
  globals: on
})

elliptic = require 'elliptic'
curve = new elliptic.ec('curve25519')

hash = require './hash'

TEST_ADDRESSES = {
  "DAN": {
    "pub": "052b220ffabfeddc24445607d31e056f792bcdbdf60765279d1ace523a985cb0",
    "prv": "DANDANDANDANDANDANDANDANDANDAN"
  },
  "BOB": {
    "pub": "37758c968000fe87ca7d6448a0d12b9819e0032571f7c1db881d9cd7edc5b4e4",
    "prv": "BOBBOBBOBBOBBOBBOBBOBBOBBOBBOB"
  },
  "JOHN": {
    "pub": "103379888379c81b98502c2c76655a2479eb758088a379b3682611718253da40",
    "prv": "JOHNJOHNJOHNJOHNJOHNJOHNJOHNJO"
  },
  "LARRY": {
    "pub": "0b295149ff0517075dff2cbb2c542e7957aedcf6cb64f9aa1a8d1289fb65330d",
    "prv": "LARRYLARRYLARRYLARRYLARRYLARRY"
  }
}

# export
module.exports = addresses = {
  TEST_ADDRESSES
}

addresses.get_public_key = ((prv) ->
  return curve.keyFromPrivate(prv,'hex').getPublic().encode('hex')
)

addresses._to_hex_str = ((arr) ->
  return (_.map Array.from(arr), (byte) ->
    return ('0' + (byte & 0xFF).toString(16)).slice(-2)
  ).join('')
)

##
if !module.parent
  log /TEST/

  #log addresses._to_hex_str('hello, world')

  ###
  tmp = {}

  for k,v of addresses.TEST_ADDRESSES
    tmp[k] = {
      pub: addresses.get_public_key(v.prv)
      prv: v.prv
    }

  log JSON.stringify(tmp,null,2)
  ###

  exit 0

