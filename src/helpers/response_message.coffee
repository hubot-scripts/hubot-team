class ResponseMessage
  constructor: (@teamManager)->

  createTeam: (teamName, result)->
    if result
      "#{@teamLabel(teamName)} created, add some people to it"
    else
      "#{teamName} team already exists"

  deleteTeam: (teamName, result)->
    if result
      "Team `#{teamName}` removed"
    else
      "`#{teamName}` team does not exist"

  listTeams: (teamCount, teams)->
    if teamCount > 0
      message = "Teams:\n"

      for index, team of teams
        continue if team.name is @teamManager.defaultTeamName
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


  adminRequired: ->  "Sorry, only admins can remove teams"


  addUserToTeam: (teamName, user, result)->
    switch result
      when undefined then  message = "`#{teamName}` team does not exist"
      when false then  message = "#{user} already in the #{@teamLabel(teamName)}"
      when true
        teamData = @teamManager.teams()[teamName] || @teamManager.defaultTeam()
        team = @teamManager.teamFor(teamData)

        if  team.size() > 0
          countMessage = ", " + team.size()
          countMessage += " others are in" if team.size() > 1
          countMessage += " other is in" if team.size() is 1
        message = "#{user} added to the #{@teamLabel(teamName)}"
        message += countMessage if countMessage
    message

  removeUserFromTeam: (teamName, user, result)->
    if result
      team = @teamManager.findTeam(teamName)
      count = team.size()
      countMessage = ", " + count + " remaining" if count > 0
      message = "#{user} removed from the #{@teamLabel(teamName)}"
      message += countMessage if countMessage

      message
    else
      "#{user} already out of the #{@teamLabel(teamName)}"

  teamCount: (teamName)->
    unless @teamManager.teamExists(teamName)
      "`#{teamName}` team does not exist"
    else
      teamData = @teamManager.teams()[teamName]
      team = @teamManager.teamFor(teamData)
      "#{team.size()} people are currently in the team"

  listUsersInTeam: (teamName)->
    unless @teamManager.teamExists(teamName)
      response = "`#{teamName}` team does not exist"
    else
      teamData = @teamManager.teams()[teamName]
      team = @teamManager.teamFor(teamData)
      count = team.size()
      if count is 0
        response = "There is no one in the #{@teamLabel(teamName)} currently"
      else
        position = 0
        response = "#{@teamLabel(teamName)} (#{count} total):\n"
        for user in team.players()
          position += 1
          response += "#{position}. #{user}\n"
    response

  teamCleared: (teamName)->
    "#{@teamLabel(teamName)} list cleared"

  # private

  teamLabel: (teamName) ->
    label = teamName unless teamName is @teamManager.defaultTeamName
    message = if label then "`#{label}` team" else "team"

  normalizeUser: (username, userInput)->
    if not userInput? or (userInput?.toLocaleLowerCase() is 'me')
      return '@' + username
    '@' + userInput.replace /@*/g, ''

  config: ()->
    @_config||= require("./config")

module.exports = ResponseMessage
