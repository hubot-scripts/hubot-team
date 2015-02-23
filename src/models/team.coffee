Config = require './config'

class Team
  constructor: (@name, @_players = [])->

  players: ->
    @_players or= []

  label: ->
    return 'team' if @name is Config.defaultTeamLabel
    "`#{@name}` team"

  clear: ->
    @_players = []

  addPlayer: (player)->
    @_players.push player

  size: ->
    @players().length

module.exports = Team
