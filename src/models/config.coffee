class Config
  @defaultTeamLabel = '__default__'
  @adminList = -> process.env.HUBOT_TEAM_ADMIN
  @admins = ->
    if @adminList()
      @adminList().split ','
    else
      []

module.exports = Config
