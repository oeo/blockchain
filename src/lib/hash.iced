log = (x...) -> try console.log x...

crypto = require 'crypto'

module.exports = hash = {

  sha256: ((x) ->
    if typeof x isnt 'string'
      x = JSON.stringify(x)
    return crypto.createHash('sha256').update(x).digest('hex')
  )

}

if !module.parent
  log hash.sha256({hello:1})

