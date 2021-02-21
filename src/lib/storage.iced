if !module.parent
  global.CONFIG = (require('dotenv').config({
    path: __dirname + '/../../config'
  })).parsed

_ = require('wegweg')({
  globals: on
  shelljs: on
})

Redis = require 'ioredis'
leveldb = require 'level'

module.exports = storage = {
  leveldb: leveldb(CONFIG.LEVELDB_FILENAME,{})
  redis: new Redis(CONFIG.REDIS_URI)
}

module.exports = storage

## test
if !module.parent

  log /testing leveldb/
  log /storing key/

  await storage.leveldb.put 'test-key', JSON.stringify({
    value: true
  }), defer e,r
  if e then throw e

  log /stored key/
  log /getting key/

  await storage.leveldb.get 'test-key', defer e,r
  if e then throw e

  log /got key/, r

  stream = storage.leveldb.createReadStream({
    keys: on
    values: on
  })

  stream.on 'data', (d) ->
    log /got data/, d

  await stream.on 'end', defer()

  log /clearing leveldb/

  await storage.leveldb.clear defer e
  if e then throw e

  log /finished iterating leveldb/
  exit 0

