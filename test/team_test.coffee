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


describe 'hubot-team', ->
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

  describe 'create a team', ->
    it 'shows a message when team is created successfully', (done)->
      messageHelper.sendMessage(done, 'hubot create soccer team', (result)->
        expect(result[0]).to.equal('`soccer` team created, add some people to it')
      )

    describe 'failure', ->
      it 'shows a message when team is already been created', (done)->
        Team.create('soccer')
        messageHelper.sendMessage(done, 'hubot create soccer team', (result)->
          expect(result[0]).to.equal('`soccer` team already exists')
        )

  describe '(delete|remove) a team', ->
    it 'shows a message when team does not exist', (done) ->
      messageHelper.sendMessage(done, 'hubot delete soccer team', (result)->
        expect(result[0]).to.equal('`soccer` team does not exist'))

    it 'shows a message when team is removed successfully', (done) ->
      Team.create('soccer')
      messageHelper.sendMessage(done, 'hubot delete soccer team', (result)->
        expect(result[0]).to.equal('`soccer` team removed'))

    it 'shows a message if an admin is required', (done) ->
      Team.create('soccer')
      messageHelper.replyMessageWithNoAdmin(done, 'hubot delete soccer team', (result)->
        expect(result[0]).to.equal('Sorry, only admins can perform this operation'))

  describe 'list teams', ->
    it 'shows the teams without members', (done)->
      Team.create('soccer')
      messageHelper.sendMessage(done, 'hubot list teams', (result)->
        expect(result[0]).to.equal('Teams:\n`soccer` (empty)\n'))

    it 'shows the teams with members', (done)->
      Team.create('soccer', ['peter'])

      messageHelper.sendMessage(done, 'hubot list teams', (result)->
        expect(result[0]).to.equal('Teams:\n`soccer` (1 total)\n- peter'))

    it 'shows no team created message', (done)->
      messageHelper.sendMessage(done, 'hubot list teams', (result)->
        expect(result[0]).to.equal('No team was created so far'))

  describe 'teamName? team add (me|user)', ->
    it 'shows a message when default team already has a member', (done)->
      Team.getDefault(['mocha'])

      messageHelper.sendMessage(done, 'hubot team add me', (result)->
        expect(result[0]).to.equal('mocha already in the team'))

    it 'shows a message when new member is added to the default team', (done)->
      messageHelper.sendMessage(done, 'hubot team add me', (result)->
        expect(result[0]).to.equal('mocha added to the team'))

    it 'shows a message when team does not exist', (done)->
      messageHelper.sendMessage(done, 'hubot soccer team add peter', (result)->
        expect(result[0]).to.equal('`soccer` team does not exist'))

    it 'shows a message when member is already in the team', (done)->
      Team.create('soccer', ['peter'])
      messageHelper.sendMessage(done, 'hubot soccer team add peter', (result)->
        expect(result[0]).to.equal('peter already in the `soccer` team'))

    it 'shows a message when user is new in team', (done)->
      Team.create('soccer')
      messageHelper.sendMessage(done, 'hubot soccer team add peter', (result)->
        expect(result[0]).to.equal('peter added to the `soccer` team'))

  describe 'teamName? team +1', ->
    describe 'team name given', ->
      it 'shows a message if user is added to the given team', (done)->
        Team.create('soccer')
        messageHelper.sendMessage(done, 'hubot soccer team +1', (result)->
          expect(result[0]).to.equal('mocha added to the `soccer` team'))

    describe 'team name not given (default team)', ->
      it 'shows a message if user is added to the default team', (done)->
        messageHelper.sendMessage(done, 'hubot team +1', (result)->
          expect(result[0]).to.equal('mocha added to the team'))

  describe 'teamName? team remove member', ->
    it 'shows a message when user does not exist in team', (done)->
      messageHelper.sendMessage(done, 'hubot team remove peter', (result)->
        expect(result[0]).to.equal('peter already out of the team'))

    it 'shows a message when user exists in team', (done)->
      Team.create('soccer', ['peter', '@james'])
      messageHelper.sendMessage(done, 'hubot soccer team remove peter', (result)->
        expect(result[0]).to.equal('peter removed from the `soccer` team, 1 remaining'))

  describe 'teamName? team -1', ->
    it 'shows a message when user exists in team', (done)->
      Team.create('soccer', ['mocha'])

      messageHelper.sendMessage(done, 'hubot soccer team -1', (result)->
        expect(result[0]).to.equal('mocha removed from the `soccer` team'))

    it 'shows a message when user exists in team', (done)->
      Team.getDefault(['mocha'])

      messageHelper.sendMessage(done, 'hubot team -1', (result)->
        expect(result[0]).to.equal('mocha removed from the team'))

  describe 'teamName? team count', ->
    it 'shows the count with team members', (done)->
      Team.create('soccer', ['mocha'])

      messageHelper.sendMessage(done, 'hubot soccer team count', (result)->
        expect(result[0]).to.equal('1 people are currently in the team'))

  describe 'teamName? team list|show', ->
    it 'shows a message listing the members in a team', (done)->
      Team.create('soccer', ['mocha', 'peter'])
      messageHelper.sendMessage(done, 'hubot soccer team list', (result)->
        expect(result[0]).to.equal('`soccer` team (2 total):\n1. mocha\n2. peter\n'))

    it 'shows a message when default team does not have any member', (done)->
      messageHelper.sendMessage(done, 'hubot team list', (result)->
        expect(result[0]).to.equal('There is no one in the team currently'))

  describe 'teamName? team clear|empty', ->
    it 'shows a message when members have been removed', (done)->
      Team.create('soccer', ['mocha', 'peter'])

      messageHelper.sendMessage(done, 'hubot soccer team clear', (result)->
        expect(result[0]).to.equal('`soccer` team list cleared'))

    describe 'default team', ->
      it 'shows a message when members have been removed', (done)->
        Team.getDefault(['mocha', 'peter'])

        messageHelper.sendMessage(done, 'hubot team clear', (result)->
          expect(result[0]).to.equal('team list cleared'))

  describe 'upgrade teams', ->
    it 'upgrade old structure and show the team list', (done)->
      robot.brain.data.teams = {team1: ['member1', 'member2'], team2: ['member3', 'member4']}
      messageHelper.sendMessage(done, 'hubot upgrade teams', (result)->
        expect(result[0]).to.equal("Teams:\n`team1` (2 total)\n- member1\n- member2`team2` (2 total)\n- member3\n- member4"))
