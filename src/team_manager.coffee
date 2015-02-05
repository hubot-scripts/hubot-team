Team = require("./models/team")

class TeamManager
  defaultTeamName: "__default__"

  constructor: (robot)->
    @robot = robot

  createTeam: (name)->
    return false if @teamExists(name)
    @teams()[name] = new Team(name)

  removeTeam: (name)->
    return unless @teamExists(name)

    unless name is @defaultTeamName
      delete @teams()[name]
      true
    else
      false


  # change return and return boolean raise errors
  addUserToTeam: (user, teamName)->
    return if teamName && !@teamExists(teamName)
    teamName = @defaultTeam().name  unless teamName

    team = @findTeam teamName
    if user in team.players()
      false
    else
      team.players().push(user)
      @teams()[teamName] = team
      true

  removeUserFromTeam: (user, teamName) ->
    teamName = @defaultTeamName unless teamName
    return unless @teamExists(teamName)

    team = @findTeam teamName
    if user not in team.players()
      false
    else
      userIndex = team.players().indexOf(user)
      team.players().splice(userIndex, 1)
      @teams()[teamName] = team
      true


  teamExists: (name)->
    return @defaultTeam() && true if name is @defaultTeamName
    @teams()[name]

  defaultTeam: ->
    @teams()[@defaultTeamName] or= new Team(@defaultTeamName)

  destroyDefaultTeam: ->
    @teams()[@defaultTeamName] = null

  hasDefaultTeam: ->
    @teams()[@defaultTeamName]

  teams: ->
    @robot.brain.data.teams or= {}

  teamsCount: ->
    @_teamCount ||= Object.keys(@teams()).length

  findTeam: (name)->
    name = @defaultTeamName unless name
    teamData = @teams()[name]
    new Team(teamData.name, teamData._players)

  teamFor: (teamData)->
    new Team(teamData.name, teamData._players)

  upgradeTeam: ->
    teams = {}
    for index, team of @teams()
      if team instanceof Array
        teams[index] = new Team(index, team)
      else
        teams[index] = team

    @robot.brain.data.teams = teams


module.exports = TeamManager
