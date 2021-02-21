global.CONFIG = (require('dotenv').config({
  path: __dirname + '/../config'
})).parsed

_ = require('wegweg')({
  globals: on
  shelljs: on
})

inquirer = require 'inquirer'
chalk = require 'chalk'
spinner = require('ora')()

BASE_URL = _.arg('node') or CONFIG.NODE_REST_URL
NODE_METADATA = null
LAST_BLOCK = null
ATTEMPTS = 0

####
help = (->
  log """
    Usage: . [options]
    Options:
      --solver <address>\t\tSpecify block block reward address
      --node <url>\t\tSpecify node REST endpoint
      --easy\t\tPrioritize easy transactions
      --hard\t\tPrioritize hard transactions
  """
)

mine = ((opt={},cb) ->
  _update_spinner = (-> spinner.start('Mining, attempts=' + ATTEMPTS))
  _heartbeat (e) ->
    if e
      await setTimeout defer(), 100
      return mine(opt,cb)
    else
      setInterval _heartbeat, 100

    while 1
      await _gather_block opt, defer e,block
      if e then continue

    _update_spinner()
)

_gather_block = ((opt,cb=null) ->
  if !cb then cb = -> 1
  spinner.start 'Gathering a block'
  await setTimeout defer(), 10
  return cb()
)

HEARTBEAT_WORKING = false

_heartbeat = ((cb=null) ->
  if !cb then cb = -> 1

  return cb(new Error 'Heartbeat already working') if HEARTBEAT_WORKING
  HEARTBEAT_WORKING = true

  await _.get BASE_URL, defer e,r,b

  if e or !b?.last_block?.hash
    HEARTBEAT_WORKING = false
    return cb(e)

  if b?.last_block?.hash isnt LAST_BLOCK?.hash
    spinner.stopAndPersist(symbol:'👂',text:'Last block changed')
    log b.last_block
    spinner.start()

    NODE_METADATA = b
    LAST_BLOCK = b.last_block

  HEARTBEAT_WORKING = false
  return cb()
)

####
if _.arg('help')
  help()
  exit 0
else
  spinner.info('Using node ' + BASE_URL)
  mine {}, -> 1

