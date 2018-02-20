_ = require('wegweg')({
  globals: on
})

blockchain = require './blockchain'
transactions = require './transactions'
peers = require './peers'

app = _.app()

app.get '/', ((req,res,next) ->
  await blockchain.get_last_block defer e,block
  if e then return next e

  return res.json {
    height: block.index
    difficulty: block.difficulty
    last_block: block
  }
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

# coin balances
app.get '/balances', ((req,res,next) ->
  await blockchain.get_balances defer e,balances
  if e then return next e

  return res.json balances
)

# single address balance
app.get '/balances/:address', ((req,res,next) ->
  await blockchain.get_balance req.params.address, defer e,balance
  if e then return next e

  return res.json(balance)
)

# single transaction
app.get '/transactions/:hash', ((req,res,next) ->
  return next new Error '@todo'
)

# peers
app.get '/peers', ((req,res,next) ->
  return res.json true
)

app.get '/peers-add', ((req,res,next) ->
  peers.connect(req.query.ip)
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
        amount: 1
      }]
    }

    await transactions.create txn_opt, defer e,transaction

    block_data = {
      transactions: [transaction]
    }

  await blockchain.generate_next_block block_data, solver.pub, defer e,next_block
  if e then return next e

  log /next_block/
  log next_block

  await blockchain.add_block next_block, defer e
  if e then return next e

  return res.json(next_block)
)

##
module.exports = app

