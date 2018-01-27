config = (require('dotenv').config({
  path: __dirname + '/../config'
})).parsed

_ = require('wegweg')({
  globals: on
})

blockchain = require './lib/blockchain'
http_server = require './lib/server-http'
websocket_server = require './lib/server-websocket'

log "rdy@#{_.time()}", config

