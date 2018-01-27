_ = require('wegweg')({
  globals: on
})

blockchain = require './lib/blockchain'

module.exports = app = _.app({bare:true})

app.get '/', ((req,res,next) ->
  return res.json pong:_.time()
)
app.get '/blocks', ((req,res,next) ->
  await blockchain.get_blockchain defer e,chain
  if e then return next e

  return res.json chain
)
app.get '/', ((req,res,next) ->
  return res.json pong:_.time()
)
app.get '/', ((req,res,next) ->
  return res.json pong:_.time()
)




