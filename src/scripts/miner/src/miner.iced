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
SOLVER_ADDRESS = _.arg('solver') or CONFIG.SOLVER_ADDRESS
NODE_METADATA = null
LAST_BLOCK = null

ATTEMPTS = 0

####
help = (->
  log """
    Usage: . [options]
    Options:
      --solver <addr>\tSpecify block block reward address
      --node <url>\t\tSpecify node REST endpoint
      --easy\t\tPrioritize easy transactions
      --hard\t\tPrioritize hard transactions
  """
)

####
mine = ((opt={},cb) ->
  _update_spinner = -> spinner.start('Mining a block. ATTEMPTS=' + ATTEMPTS)
  _heartbeat (e) ->
    if e
      await setTimeout defer(), 100
      return mine(opt,cb)
    else
      setInterval _heartbeat, 100

    await _get_solver_address defer e,pub
    if e then throw e

    SOLVER_ADDRESS = pub
    spinner.stopAndPersist(symbol:'🔑',text:'Solver: ' + SOLVER_ADDRESS)

    while 1
      await _gather_block opt, defer e,block
      if e then continue

    _update_spinner()
)

_get_solver_address = ((cb=null) ->
  if SOLVER_ADDRESS
    return cb null, SOLVER_ADDRESS

  # use dotfile
  if _.exists(SOLVER_DOTFILE = require('os').homedir() + '/.gradient.json')
    try
      obj = JSON.parse(_.reads SOLVER_DOTFILE)
    catch e
      throw new Error 'Unable to parse JSON from existing file ' + SOLVER_DOTFILE

    if !obj?.pub then throw new Error 'JSON key `pub` missing from from object ' + SOLVER_DOTFILE
    spinner.stopAndPersist(symbol:'🔑',text:'Using `pub` address from dotfile ' + SOLVER_DOTFILE)

    return cb null, obj.pub

  # generate address
  else
    await _.get BASE_URL + '/wallets?method=post', defer e,r,b
    if e then throw e

    if !b?.pub
      throw new Error 'Malformed JSON from server when generating solver address'

    _.writes SOLVER_DOTFILE, JSON.stringify(b)
    spinner.stopAndPersist(symbol:'🔑',text:'Generated rewards keypair and wrote file ' + _.base(SOLVER_DOTFILE))

    return cb null, b.pub
)

_gather_block = ((opt,cb=null) ->
  if !cb then cb = -> 1
  spinner.start 'Constructing a block from the mempool'

  await setTimeout defer(), 3000

  return cb null, true
)

# @todo
_alert_block_mined = ((block) ->
  spinner.stopAndPersist(symbol:'💎',text:'Solved block ' + block.hash)
)

_output_json = ((obj) ->
  str = JSON.stringify(obj,null,2)
  arr = _.map str.split('\n'), (line) ->
    line = '> ' + line
    return line
  return arr.join '\n'
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
    spinner.stopAndPersist(symbol:'🔔',text:'New block')
    log chalk.dim _output_json(b.last_block)
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
  spinner.stopAndPersist(symbol:'🔩',text:'Node endpoint ' + BASE_URL)
  mine {}, -> 1

