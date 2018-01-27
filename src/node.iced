global.PROCESS_STARTED = new Date

global.CONFIG = (require('dotenv').config({
  path: __dirname + '/../config'
})).parsed

_ = require('wegweg')({
  globals: on
})

log _.reads(ascii) if _.exists(ascii = __dirname + '/../ascii.art')
log CONFIG

blockchain = require './lib/blockchain'

http_server = require './lib/server-http'
http_server.listen(CONFIG.HTTP_PORT)

websocket_server = require './lib/server-websocket'
#websocket_server.listen(env.WEBSOCKET_PORT)

