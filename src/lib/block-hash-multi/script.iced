_ = require('wegweg')({
  globals: on
})

common = require './lib/common'

hash_block = ((data,prev_hash) ->
  metadata = {
    data: data
    prev_hash: prev_hash
    fns: []
  }

  nibbles = prev_hash.slice(-20).split('')

  for char in nibbles
    metadata.fns.push(common.find_fn(char))

  data = JSON.stringify(data) if _.type(data) isnt 'string'
  hash_value = common.sha256(data)

  for hash_fn in metadata.fns
    hash_value = common[hash_fn](hash_value)
    log "#{hash_fn}()", hash_value

  hash_value = common.sha256(hash_value)

  return hash_value
)

##
if module.parent
  module.exports = hash_block

else

  fake_block = {
    height: 33
    data: {
      lorem: 'ipsum'
    }
  }

  prev_hash = common.sha256('GENESIS')

  result = hash_block(fake_block,prev_hash)
  log 'Block hash:', result

