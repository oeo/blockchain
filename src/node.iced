require('dotenv').config({path: __dirname + '/../.env'})

_ = require('wegweg')({
  globals: on
})

blockchain = require './lib/blockchain'
http_server = require './lib/server-http'
websocket_server = require './lib/server-websocket'

log "rdy@#{new Date}"

