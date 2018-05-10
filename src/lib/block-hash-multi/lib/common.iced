_ = require('wegweg')({
  globals: on
})

crypto = require 'crypto'
multi = require './multi-hashing-bbscoin'

common = {
  LIST: []
  MULTI: []
}

# add multi
for multi_fn in _.fns(multi)
  continue if multi_fn in [
    'bcrypt'
    'scrypt'
    'scryptn'
    'boolberry'
    'sha1'
  ]

  do (multi_fn) ->
    common.MULTI.push(fn_name = 'MULTI_' + multi_fn)
    common.LIST.push(fn_name)

    common[fn_name] = (str) ->
      x = multi[multi_fn](Buffer.from(str,'utf8'))
      return x.toString('hex')

# add sha1/sha256/sha512
common.LIST.push 'sha1'
common.sha1 = ((str) ->
  x = crypto.createHash('sha1')
  x.update Buffer.from(str,'utf8')
  return x.digest('hex')
)

common.LIST.push 'sha256'
common.sha256 = ((str) ->
  x = crypto.createHash('sha256')
  x.update Buffer.from(str,'utf8')
  return x.digest('hex')
)

common.LIST.push 'sha512'
common.sha512 = ((str) ->
  x = crypto.createHash('sha512')
  x.update Buffer.from(str,'utf8')
  return x.digest('hex')
)

common.find_fn = ((char) ->
  chars = "0123456789abcdef".split('')
  return common.MULTI[chars.indexOf(char)]
)

##
if !module.parent
  log common.LIST

  for x in common.LIST
    log "`#{x}()`", common[x]('GENESIS')
else
  module.exports = common

