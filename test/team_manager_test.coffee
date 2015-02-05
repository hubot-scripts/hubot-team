chai = require 'chai'
expect = chai.expect

helper = require 'hubot-mock-adapter-helper'
TeamManager = require "../src/team_manager"


describe "TeamManager", ->
  {robot, user, adapter} = {}
  teamManager = null

  before (done)->
    helper.setupRobot (ret) ->
      {robot, user, adapter} = ret
      do done

  after ->
    robot.shutdown()

  beforeEach ->
    teamManager = new TeamManager(robot)
    robot.brain.data.teams = {}

  describe "#createTeam" , ->
    describe "when team doesnt exist", ->
      it "should save a new team", ->
        expect(teamManager.createTeam("junior")).to.not.equal(false)
        expect(robot.brain.data.teams["junior"]).to.be.a('object')

    describe "when team exists", ->
      beforeEach ->
        robot.brain.data.teams or= {}
        robot.brain.data.teams["junior"] = {}
      it "should not save the new team", ->
        expect(teamManager.createTeam("junior")).to.equal(false)

  describe "#removeTeam" , ->
    describe "when team doesnt exist", ->
      it "should return undefined", ->
        expect(teamManager.removeTeam("junior")).to.equal(undefined)

    describe "when team exists", ->
      beforeEach ->
        robot.brain.data.teams or= {}
        robot.brain.data.teams["junior"] = {}

      it "should remove team", ->
        expect(teamManager.removeTeam("junior")).to.equal(true)


      it "should remove the team if this default", ->
        robot.brain.data.teams["__default__"] = {}
        expect(teamManager.removeTeam("__default__")).to.equal(false)

  describe "#addUserToTeam", ->
    describe "without team name", ->
      it "should create default team", ->
        expect(teamManager.addUserToTeam("peter")).to.equal(true)
        expect(robot.brain.data.teams["__default__"].players().length).to.equal(1)

    describe "with team name", ->
      describe "when team name doesnt exist", ->
        it "should return undefined", ->
          expect(teamManager.addUserToTeam("peter", "junior")).to.equal(undefined)

      describe "when team name exists", ->
        it "should save new player", ->
          teamManager.createTeam("junior")
          expect(teamManager.addUserToTeam("peter", "junior")).to.equal(true)
          expect(robot.brain.data.teams["junior"].players().length).to.equal(1)

      describe "when player already exist in the team", ->
        it "should return false", ->
          teamManager.createTeam("junior").players().push("peter")
          expect(teamManager.addUserToTeam("peter", "junior")).to.equal(false)
          expect(robot.brain.data.teams["junior"].players().length).to.equal(1)

  describe "#teamExists", ->
    it "should return object  if it exists", ->
      teamManager.createTeam("junior")
      expect(teamManager.teamExists("junior")).to.not.equal(undefined)

    it "should return undefined if it exists", ->
      expect(teamManager.teamExists("junior")).to.equal(undefined)

  describe "#removeUserFromTeam", ->
    describe "when team doesnt exist", ->
      it "should return undefined", ->
        expect(teamManager.removeUserFromTeam("peter", "junior")).to.equal(undefined)
    describe "when team exist", ->
      it "when player already exist in the team", ->
        teamManager.createTeam("junior").players().push("peter")
        expect(teamManager.removeUserFromTeam("peter", "junior")).to.equal(true)
        expect(robot.brain.data.teams["junior"].players().length).to.equal(0)

      it "when player is new in team", ->
        teamManager.createTeam("junior")
        expect(teamManager.removeUserFromTeam("peter", "junior")).to.equal(false)

  describe "#teamsCount", ->
    describe "when team list is empty", ->
      it "should return 0", ->
        expect(teamManager.teamsCount()).to.equal(0)

    describe "when team list is not empty", ->
      it "should return the qty", ->
        robot.brain.data.teams["junior"] = {}
        expect(teamManager.teamsCount()).to.equal(1)



