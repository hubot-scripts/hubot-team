# Description:
#   Create a team using hubot
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_TEAM_ADMIN - A comma separate list of user names
#
# Commands:
#   hubot create <team_name> team - create team called <team_name>
#   hubot (delete|remove) <team_name> team - delete team called <team_name>
#   hubot list teams - list all existing teams
#   hubot (<team_name>) team +1 - add me to the team
#   hubot (<team_name>) team -1 - remove me from the team
#   hubot (<team_name>) team add (me|<user>) - add me or <user> to team
#   hubot (<team_name>) team remove (me|<user>) - remove me or <user> from team
#   hubot (<team_name>) team count - list the current size of the team
#   hubot (<team_name>) team (list|show) - list the people in the team
#   hubot (<team_name>) team (empty|clear) - clear team list
#   hubot upgrade teams-  upgrade team for the new structure
#
# Author:
#   mihai
config =
  adminList: process.env.HUBOT_TEAM_ADMIN,

TeamManager = require "./team_manager"
ResponseMessage = require "./helpers/response_message"

module.exports = (robot) ->
  robot.brain.data.teams or= {}
  robot.brain.data.playerStats or= []
  teamManager = new TeamManager(robot)
  responseMessage = new ResponseMessage(teamManager)

  unless config.adminList?
    robot.logger.warning 'The HUBOT_TEAM_ADMIN environment variable not set'

  if config.adminList?
    admins = config.adminList.split ','
  else
    admins = []

  ##
  ## hubot create <team_name> team - create team called <team_name>
  ##
  robot.respond /create (\S*) team ?.*/i, (msg) ->
    teamName = msg.match[1]
    result= teamManager.createTeam(teamName)

    msg.send responseMessage.createTeam(teamName, result)

  ##
  ## hubot (delete|remove) <team_name> team - delete team called <team_name>
  ##
  robot.respond /(delete|remove) (\S*) team ?.*/i, (msg) ->
    teamName = msg.match[2]
    name = msg.message.user.name
    return msg.reply responseMessage.adminRequired() unless name in admins
    result = teamManager.removeTeam(teamName)
    msg.send responseMessage.deleteTeam(teamName, result)


  ##
  ## hubot list teams - list all existing teams
  ##
  robot.respond /list teams ?.*/i, (msg) ->
    teamCount = teamManager.teamsCount()
    teamCount = teamCount - 1 if teamManager.hasDefaultTeam()
    teams = teamManager.teams()

    msg.send responseMessage.listTeams(teamCount, teams)

  ##
  ## hubot <team_name> team add (me|<user>) - add me or <user> to team
  ##
  robot.respond /(\S*)? team add @?(\S*) ?.*/i, (msg) ->
    teamName = msg.match[1]
    user = responseMessage.normalizeUser(msg.message.user.name, msg.match[2])
    result = teamManager.addUserToTeam(user, teamName)
    msg.send responseMessage.addUserToTeam(teamName, user, result)

  ##
  ## hubot <team_name> team +1 - add me to the team
  ##
  robot.respond /(\S*)? team \+1 ?.*/i, (msg) ->
    teamName = msg.match[1]
    user = responseMessage.normalizeUser(msg.message.user.name)
    result = teamManager.addUserToTeam(user, teamName)
    msg.send responseMessage.addUserToTeam(teamName, user, result)

  ##
  ## hubot <team_name> team remove (me|<user>) - remove me or <user> from team
  ##
  robot.respond /(\S*)? team remove (\S*) ?.*/i, (msg) ->
    teamName = msg.match[1]
    user = responseMessage.normalizeUser(msg.message.user.name, msg.match[2])
    result = teamManager.removeUserFromTeam(user, teamName)
    msg.send responseMessage.removeUserFromTeam(teamName, user, result)

  ##
  ## hubot <team_name> team -1 - remove me from the team
  ##
  robot.respond /(\S*)? team -1/i, (msg) ->
    teamName = msg.match[1] or teamManager.defaultTeamName
    user = responseMessage.normalizeUser(msg.message.user.name)
    result = teamManager.removeUserFromTeam(user, teamName)
    msg.send responseMessage.removeUserFromTeam(teamName, user, result)

  ##
  ## hubot <team_name> team count - list the current size of the team
  ##
  robot.respond /(\S*)? team count$/i, (msg) ->
    teamName = msg.match[1] or teamManager.defaultTeamName
    msg.send responseMessage.teamCount(teamName)

  ##
  ## hubot <team_name> team (list|show) - list the people in the team
  ##
  robot.respond /(\S*)? team (list|show)$/i, (msg) ->
    teamName = msg.match[1] or teamManager.defaultTeamName
    msg.send responseMessage.listUsersInTeam(teamName)

  ##
  ## hubot <team_name> team (empty|clear) - clear team list
  ##
  robot.respond /(\S*)? team (clear|empty)$/i, (msg) ->
    teamName = msg.match[1] or teamManager.defaultTeamName
    user = msg.message.user.name
    return msg.reply(responseMessage.adminRequired()) unless user in admins
    teamManager.teamFor(teamName).clear()
    msg.send responseMessage.teamCleared(teamName)

  ##
  ## hubot upgrade teams - upgrade team for the new structure
  ##
  robot.respond /upgrade teams$/i, (msg) ->
    teamManager.upgradeTeam()
    msg.send responseMessage.listTeams()
