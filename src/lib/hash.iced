_ = require('wegweg')({
  globals: on
})

crypto = require 'crypto'

# @todo: cryptonite-lite
module.exports = hash = {

  # use env algo
  auto: ((x...) ->
    if !this[algo = env.HASHING_ALGO]
      throw new Error 'Hashing function not found', algo
      exit 1
    return this[algo](x...)
  )

  sha256: ((x) ->
    x = JSON.stringify(x) if typeof x isnt 'string'
    return crypto.createHash('sha256').update(x).digest('hex')
  )

  # lel
  md5: ((x) ->
    x = JSON.stringify(x) if typeof x isnt 'string'
    return _.md5(x)
  )

}

##
if !module.parent
  log /TEST/
  log hash.sha256({hello:1})

