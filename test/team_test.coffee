path        = require 'path'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
helper      = require 'hubot-mock-adapter-helper'
TextMessage = require('hubot/src/message').TextMessage
Team        = require '../src/models/team'

chai.use require 'sinon-chai'

class Helper
  constructor: (@robot, @adapter, @user)->

  replyMessageWithNoAdmin: (done, message, callback)->
    @sendMessageHubot({name: 'noadmin'}, message, callback, done, 'reply')

  replyMessage: (done, message, callback)->
    @sendMessageHubot(@user, message, callback, done, 'reply')

  sendMessageWithNoAdmin: (done,  message, callback)->
    @sendMessageHubot({name: 'noadmin'}, message, callback, done, 'send')

  sendMessage: (done, message, callback)->
    @sendMessageHubot(@user, message, callback, done, 'send')

  sendMessageHubot: (user, message, callback, done, event)->
    @adapter.on event, (envelop, string) ->
      try
        callback(string)
        done()
      catch e
        done e
    @adapter.receive new TextMessage(user, message)


describe 'hubot team', ->
  {robot, user, adapter} = {}
  messageHelper = null

  beforeEach (done)->
    helper.setupRobot (ret) ->
      process.setMaxListeners(0)
      {robot, user, adapter} = ret
      messageHelper = new Helper(robot, adapter, user)
      process.env.HUBOT_TEAM_ADMIN = user['name']
      do done

  afterEach ->
    robot.shutdown()

  beforeEach ->
    require('../src/team')(robot)

  describe 'create some team', ->
    it 'success', (done)->
      robot.brain.data.teams = {}
      messageHelper.sendMessage(done, 'hubot create junior team', (result)->
        expect(result[0]).to.equal('`junior` team created, add some people to it')
      )

    it 'failure', (done)->
      robot.brain.data.teams = {}
      robot.brain.data.teams['junior'] = new Team('junior')

      messageHelper.sendMessage(done, 'hubot create junior team', (result)->
        expect(result[0]).to.equal('junior team already exists')
      )

  describe 'delete|remove some team', ->
    it 'does not exists', (done) ->
      messageHelper.sendMessage(done, 'hubot delete junior team', (result)->
        expect(result[0]).to.equal('`junior` team does not exist'))

    it 'success', (done) ->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = { name: 'junior' }

      messageHelper.sendMessage(done, 'hubot delete junior team', (result)->
        expect(result[0]).to.equal('Team `junior` removed'))

    it 'failure', (done) ->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = new Team('junior')
      messageHelper.replyMessageWithNoAdmin(done, 'hubot delete junior team', (result)->
        expect(result[0]).to.equal('Sorry, only admins can remove teams'))


  describe 'list teams', ->
    it 'should show the teams without players', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = { name: 'junior' }

      messageHelper.sendMessage(done, 'hubot list teams', (result)->
        expect(result[0]).to.equal('Teams:\n`junior` (empty)\n'))

    it 'should show the teams with players', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = { name: 'junior', _players: ['@peter']}

      messageHelper.sendMessage(done, 'hubot list teams', (result)->
        expect(result[0]).to.equal('Teams:\n`junior` (1 total)\n- @peter\n\n'))

    it 'should show no team created message', (done)->
      messageHelper.sendMessage(done, 'hubot list teams', (result)->
        expect(result[0]).to.equal('No team was created so far'))

  describe 'teamName team add user|me', ->
    it 'should show a message when default team already have this player', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['__default__'] = {name: '__default__', _players: ['@mocha']}

      messageHelper.sendMessage(done, 'hubot team add me', (result)->
        expect(result[0]).to.equal('@mocha already in the team'))

    it 'should show a message when default added the new player', (done)->
      messageHelper.sendMessage(done, 'hubot team add me', (result)->
        expect(result[0]).to.equal('@mocha added to the team, 1 other is in'))

    it 'should show a message when team name doesn\'t exist', (done)->
      messageHelper.sendMessage(done, 'hubot junior team add peter', (result)->
        expect(result[0]).to.equal('`junior` team does not exist'))

    it 'should show a message when user is already in the team', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = {name: 'junior', _players: ['@peter']}

      messageHelper.sendMessage(done, 'hubot junior team add peter', (result)->
        expect(result[0]).to.equal('@peter already in the `junior` team'))


    it 'should show a success message when user is new in team', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = {name: 'junior'}

      messageHelper.sendMessage(done, 'hubot junior team add peter', (result)->
        expect(result[0]).to.equal('@peter added to the `junior` team, 1 other is in'))

  describe 'teamName? team +1', ->
    it 'should show a message when user do not send a team name', (done)->
      messageHelper.sendMessage(done, 'hubot team +1', (result)->
        expect(result[0]).to.equal('@mocha added to the team, 1 other is in'))

  describe '(team name) team remove (name)', ->
    it 'should show a message when user doesn\'t exist in team', (done)->
      messageHelper.sendMessage(done, 'hubot team remove @peter', (result)->
        expect(result[0]).to.equal('@peter already out of the team'))

    it 'should show a message when user exists in team', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = {name: 'junior', _players: ['@peter', '@james']}

      messageHelper.sendMessage(done, 'hubot junior team remove @peter', (result)->
        expect(result[0]).to.equal('@peter removed from the `junior` team, 1 remaining'))

  describe '(team name) team -1', ->
    it 'should show a message when user exists in team', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = { name: 'junior', _players: ['@mocha']}

      messageHelper.sendMessage(done, 'hubot junior team -1', (result)->
        expect(result[0]).to.equal('@mocha removed from the `junior` team'))

    it 'should show a message when user exists in team', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['__default__'] = { name: '__default__', _players: ['@mocha']}

      messageHelper.sendMessage(done, 'hubot team -1', (result)->
        expect(result[0]).to.equal('@mocha removed from the team'))

  describe '(team name) team count', ->
    it 'should show the count with team players', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = { name: 'junior', _players: ['@mocha']}

      messageHelper.sendMessage(done, 'hubot junior team count', (result)->
        expect(result[0]).to.equal('1 people are currently in the team'))


  describe '(team name) team list|show', ->
    it 'should list the player in a team', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = { name: 'junior', _players: ['@mocha', '@peter']}

      messageHelper.sendMessage(done, 'hubot junior team list', (result)->
        expect(result[0]).to.equal('`junior` team (2 total):\n1. @mocha\n2. @peter\n'))

    it 'should show message when defaut team doesn\'t have any player', (done)->
      robot.brain.data.teams = {}

      messageHelper.sendMessage(done, 'hubot team list', (result)->
        expect(result[0]).to.equal('There is no one in the team currently'))


  describe '(team name) team clear|empty', ->
    it 'should remove the player', (done)->
      robot.brain.data.teams or= {}
      robot.brain.data.teams['junior'] = { name: 'junior', _players: ['@mocha', '@peter']}

      messageHelper.sendMessage(done, 'hubot junior team clear', (result)->
        expect(result[0]).to.equal('`junior` team list cleared'))
