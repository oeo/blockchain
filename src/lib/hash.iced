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

  # subfns
  _hex_to_binary: ((x) ->
    str = ''
    map = {
      '0': '0000'
      '1': '0001'
      '2': '0010'
      '3': '0011'
      '4': '0100'
      '5': '0101'
      '6': '0110'
      '7': '0111'
      '8': '1000'
      '9': '1001'
      'a': '1010'
      'b': '1011'
      'c': '1100'
      'd': '1101'
      'e': '1110'
      'f': '1111'
    }

    i = 0
    while i < x.length
      if map[x[i]]
        str += map[x[i]]
      else
        return null
      i += 1

    return str
  )

}

##
if !module.parent
  log /TEST/
  log hash.sha256({hello:1})

  log hash._hex_to_binary('0000000000000000001dea4ec410fad05526369a3ae077945dbd2d9d97c1bb1a')

