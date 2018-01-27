config = (require('dotenv').config({
  path: __dirname + '/../config'
})).parsed

_ = require('wegweg')({
  globals: on
})

config.started = new Date
log config

blockchain = require './lib/blockchain'
http_server = require './lib/server-http'
websocket_server = require './lib/server-websocket'

http_server.listen(env.HTTP_PORT)
log "HTTP server listening", env.HTTP_PORT

#websocket_server.listen(env.WEBSOCKET_PORT)
#log "Websocket server listening", env.WEBSOCKET_PORT

