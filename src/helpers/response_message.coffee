Config = require '../models/config'

class ResponseMessage
  constructor: (@teamManager)->

  createTeam: (teamName, success)->
    if success
      "#{@_teamLabel(teamName)} created, add some people to it"
    else
      "#{teamName} team already exists"

  deleteTeam: (teamName, success)->
    if success
      "Team `#{teamName}` removed"
    else
      "`#{teamName}` team does not exist"

  listTeams: (teamCount, teams)->
    if teamCount > 0
      message = "Teams:\n"

      for index, team of teams
        continue if team.name is Config.defaultTeamLabel
        team = @teamManager.teamFor(team)
        if team.size() > 0
          message += "`#{team.name}` (#{team.size()} total)\n"

          for user in team.players()
            message += "- #{user}\n"
          message += "\n"
        else
          message += "`#{team.name}` (empty)\n"
      message
    else
      "No team was created so far"

  adminRequired: -> "Sorry, only admins can remove teams"

  addUserToTeam: (teamName, user, success)->
    switch success
      when undefined then message = "`#{teamName}` team does not exist"
      when false then message = "#{user} already in the #{@_teamLabel(teamName)}"
      when true
        teamData = @teamManager.teams()[teamName] or @teamManager.defaultTeam()
        team = @teamManager.teamFor(teamData)

        if team.size() > 0
          countMessage = ", " + team.size()
          countMessage += " others are in" if team.size() > 1
          countMessage += " other is in" if team.size() is 1
        message = "#{user} added to the #{@_teamLabel(teamName)}"
        message += countMessage if countMessage
    message

  removeUserFromTeam: (teamName, user, success)->
    if success
      team = @teamManager.findTeam(teamName)
      count = team.size()
      countMessage = ", " + count + " remaining" if count > 0
      message = "#{user} removed from the #{@_teamLabel(teamName)}"
      message += countMessage if countMessage

      message
    else
      "#{user} already out of the #{@_teamLabel(teamName)}"

  teamCount: (teamName)->
    if @teamManager.teamExists(teamName)
      teamData = @teamManager.teams()[teamName]
      team = @teamManager.teamFor(teamData)
      "#{team.size()} people are currently in the team"
    else
      "`#{teamName}` team does not exist"

  listUsersInTeam: (teamName)->
    if @teamManager.teamExists(teamName)
      teamData = @teamManager.teams()[teamName]
      team = @teamManager.teamFor(teamData)
      count = team.size()
      if count is 0
        response = "There is no one in the #{@_teamLabel(teamName)} currently"
      else
        position = 0
        response = "#{@_teamLabel(teamName)} (#{count} total):\n"
        for user in team.players()
          position += 1
          response += "#{position}. #{user}\n"
    else
      response = "`#{teamName}` team does not exist"
    response

  teamCleared: (teamName)->
    "#{@_teamLabel(teamName)} list cleared"

  # private

  _teamLabel: (teamName) ->
    label = teamName unless teamName is Config.defaultTeamLabel
    message = if label then "`#{label}` team" else "team"

  _config: ->
    @_config or= require './config'

module.exports = ResponseMessage
