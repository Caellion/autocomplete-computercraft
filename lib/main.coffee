require '../api.json'
provider = require './provider'

module.exports =
  activate: -> provider.loadCommands()

  getProvider: -> provider
