global.PROCESS_STARTED = new Date

global.CONFIG = (require('dotenv').config({
  path: __dirname + '/../config'
})).parsed

for k,v of process.env
  global.CONFIG[k] = v if global.CONFIG[k]

_ = require('wegweg')({
  globals: on
})

log _.reads(ascii) if _.exists(ascii = __dirname + '/../ascii.art')
log CONFIG

peers = require './lib/peers'
peers.server.listen(env.WEBSOCKET_PORT)

http_server = require './lib/server-http'
http_server.listen(CONFIG.HTTP_PORT)

