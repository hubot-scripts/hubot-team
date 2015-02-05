config =
  adminList: process.env.HUBOT_TEAM_ADMIN,
  defaultTeamLabel: '__default__'

class Team
  constructor: (@name, @_players=[])->

  players: ->
    @_players||=[]

  label: ->
    label = @name unless @name is config.defaultTeamLabel
    message = if label then "`#{label}` team" else "team"
    return message

  clear: ->
    @_players = []

  addPlayer: (player)->
    @players().push player

  size: ->
    @players().length



module.exports = Team
