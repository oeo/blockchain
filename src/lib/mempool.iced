if !module.parent
  global.CONFIG = (require('dotenv').config({
    path: __dirname + '/../../config'
  })).parsed

_ = require('wegweg')({
  globals: on
  shelljs: on
})

module.exports = mempool = {
  items: []
}

# add transaction to mempool
mempool.add = ((transaction,cb) ->
  await (require './transactions').validate transaction, defer e,valid
  if e then return cb e

  log 'Adding transaction to mempool', transaction

  @items.push transaction

  # sort transactions by total output amount, smallest first
  @items = (_.sortBy @items, (mempool_transaction) ->
    return (_.sum (mempool_transaction.outputs ? []), (outputs) ->
      if !outputs then return 0
      i = 0
      for o in outputs
        i += o.amount
      return i
    )
  )

  # @todo: broadcast new mempool item
  # ..

  return cb null, true
)

## test
if !module.parent

  log /TEST/
  exit 0

