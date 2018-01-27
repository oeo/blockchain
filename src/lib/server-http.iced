_ = require('wegweg')({
  globals: on
})

blockchain = require './blockchain'

app = _.app()

app.get '/', ((req,res,next) ->
  await blockchain.get_last_block defer e,block
  if e then return next e

  return res.json {
    height: block.index
    last_block: block
    uptime: Math.round((new Date - PROCESS_STARTED)/1000)
  }
)

# blocks
app.get '/blocks', ((req,res,next) ->
  await blockchain.get_blockchain defer e,chain
  if e then return next e

  return res.json chain
)

app.get '/blocks/:index_or_hash', ((req,res,next) ->
  await blockchain.get_block req.params.index_or_hash, defer e,block
  if e then return next e

  if !block
    return next new Error 'Block not found', req.query.q

  return res.json block
)

app.post '/blocks-add', ((req,res,next) ->
  return res.json todo:_.time()
)

# peers
app.get '/peers', ((req,res,next) ->
  return res.json todo:_.time()
)

app.post '/peers-add', ((req,res,next) ->
  return res.json todo:_.time()
)

##
module.exports = app

