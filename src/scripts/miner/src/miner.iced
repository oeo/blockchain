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
      --solver <addr>\tSpecify block reward address
      --node <url>\t\tSpecify node REST endpoint
      --sortfee\t\tPrioritize high fee transactions
  """
)

####
mine = ((opt={},cb) ->
  if !SOLVER_ADDRESS
    await _get_solver_address defer e,SOLVER_ADDRESS
    if e then throw e

  while 1

    spinner.start('Gathering a new block from the mempool..')

    await _gather_block opt, defer e,fresh_block
    if e then continue

    spinner.start('Mining a fresh block..')

    await _solve_block fresh_block, defer e,solved_block
    if e then continue
    if !solved_block then continue

    spinner.stopAndPersist(symbol:'💎',text:'Solved block ' + solved_block.hash)

    await _add_solved_block solved_block, defer e,success
    if e then continue

    setTimeout mine, 1
    break
)

_get_solver_address = ((cb=null) ->
  if SOLVER_ADDRESS
    return cb null, SOLVER_ADDRESS

  # use dotfile
  if _.exists(SOLVER_DOTFILE = require('os').homedir() + '/.blockchain.json')
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
  spinner.start 'Constructing new block from the mempool'

  # get mempool
  await _.get BASE_URL + '/', defer e,r,base
  if e then throw e

  NODE_METADATA = base
  LAST_BLOCK = NODE_METADATA.last_block

  # get mempool
  await _.get BASE_URL + '/mempool', defer e,r,mempool
  if e then throw e

  new_block = {
    index: (LAST_BLOCK.index + 1)
    ctime: _.time()
    prev: LAST_BLOCK.hash
    difficulty: NODE_METADATA.difficulty
    solver: SOLVER_ADDRESS
    data: {}
  }

  # if mempool has length
  if mempool?.length
    new_block.data.transactions = mempool.slice(0,10)

  return cb null, new_block
)

_add_solved_block = ((block,cb) ->
  if !cb then cb = -> 1
  spinner.start 'Submitting solved block', block

  await _.post BASE_URL + '/blocks', block, defer e,r,b
  if e then throw e

  return cb null, true
)

_solve_block = ((block,cb) ->
  Block = require __dirname + '/../../../lib/block'

  block.proof ?= 0
  i = 0

  while 1
    i += 1
    if i > 100000 then break

    block.hash = Block.calculate_hash(block)

    if Block.is_valid_proof(block)
      return cb null, block
    else
      block.proof = _.rand(0,Number.MAX_SAFE_INTEGER)

    await setTimeout defer(), 1

  return cb null, false
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

####
if _.arg('help')
  help()
  exit 0
else
  spinner.stopAndPersist(symbol:'🔩',text:'Node endpoint ' + BASE_URL)
  mine {}, -> 1

