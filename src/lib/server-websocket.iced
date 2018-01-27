_ = require('wegweg')({
  globals: on
})

Websocket = require 'ws'

blockchain = require './blockchain'

# primary export
websocket = {
  sockets: []
}

##
module.exports = websocket



