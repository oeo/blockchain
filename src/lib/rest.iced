_ = require('wegweg')({
  globals: on
  shelljs: on
})

addresses = require './addresses'
blockchain = require './blockchain'
transactions = require './transactions'
mempool = require './mempool'
peers = require './peers'

app = _.app()

body_parser = require 'body-parser'

app.use(body_parser.urlencoded(extended:on))
app.use(body_parser.json())

# allow method override
app.use ((req,res,next) ->
  valid_methods = [
    'post'
    'delete'
  ]

  if req.method is 'GET' and req.query.method
    method = req.query.method.toLowerCase().trim()
    return next() if method !in valid_methods

    req.method = method.toUpperCase().trim()

    if method is 'post'
      body = _.clone req.query
      try delete body.method

      req.query = {}
      req.body = body

  return next()
)

app.get '/', ((req,res,next) ->
  await blockchain.get_last_block defer e,block
  if e then return next e

  await blockchain.get_difficulty defer e,difficulty

  return res.json {
    height: block.index
    difficulty: difficulty
    mempool_size: mempool.items.length
    last_block: block
  }
)

# get mempool
app.get '/mempool', ((req,res,next) ->
  return res.json mempool.items
)

# all blocks
app.get '/blocks', ((req,res,next) ->
  await blockchain.get_blockchain defer e,chain
  if e then return next e

  return res.json chain
)

# single block
app.get '/blocks/:index_or_hash', ((req,res,next) ->
  await blockchain.get_block req.params.index_or_hash, defer e,block
  if e then return next e

  if !block
    return next new Error 'Block not found', req.query.q

  return res.json block
)

# add block
app.post '/blocks', ((req,res,next) ->
  Block = require __dirname + '/block'
  new_block = new Block(req.body)

  await blockchain.add_block new_block, defer e
  if e then return next e

  return res.json true
)

# all wallets
app.get '/wallets', ((req,res,next) ->
  await blockchain.get_balances defer e,balances
  if e then return next e

  return res.json balances
)

# single wallet
app.get '/wallets/:address', ((req,res,next) ->
  await blockchain.get_balance req.params.address, defer e,balance
  if e then return next e

  return res.json(balance)
)

# generate wallet
app.post '/wallets', ((req,res,next) ->
  return res.json(addresses.generate(req.body.priv ? null))
)

# find a transaction
app.get '/transactions/:hash', ((req,res,next) ->
  return next new Error '@todo'
)

# create and broadcast a transaction
app.post '/transactions', ((req,res,next) ->
  await transactions.create req.body, defer e,txn
  if e then return next e

  await transactions.broadcast txn, defer e,valid
  if e then return next e

  return res.json true
)

# peers
app.get '/peers', ((req,res,next) ->
  return res.json true
)

app.post '/peers', ((req,res,next) ->
  peers.connect(req.body.ip)
  return res.json true
)

# devel
app.get '/_/mine', ((req,res,next) ->
  addresses = require __dirname + '/addresses'

  solver = _.first(_.shuffle(_.keys(addresses.TEST_ADDRESSES)))
  solver = addresses.TEST_ADDRESSES[solver]

  block_data = {
    test: 1
  }

  # add test txn
  if req.query.txn_test
    test_addrs = _.shuffle(_.keys(addresses.TEST_ADDRESSES))

    from_key = test_addrs.pop()
    from = addresses.TEST_ADDRESSES[from_key]

    to_key = test_addrs.pop()
    to = addresses.TEST_ADDRESSES[to_key]

    txn_opt = {
      from: from.pub
      priv: from.priv
      outputs: [{
        to: to.pub
        amount: +(req.query.amount ? 1)
      }]
    }

    await transactions.create txn_opt, defer e,transaction

    block_data = {
      transactions: [transaction]
    }

  await blockchain.generate_next_block block_data, solver.pub, defer e,next_block
  if e then return next e

  await blockchain.add_block next_block, defer e
  if e then return next e

  return res.json(next_block)
)

##
module.exports = app

