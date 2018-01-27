_ = require('wegweg')({
  globals: on
})

global.CONFIG = (require('dotenv').config({
  path: __dirname + '/../../config'
})).parsed

