chai = require 'chai'
expect = chai.expect

Team = require "../../src/models/team"

describe "Team", ->
  team = null

  beforeEach ->
    team = new Team "junior"

  describe "#player", ->
    it "should be array", ->
      expect(team.players()).to.be.a("array")


  describe "#label", ->
    it "should show a new label", ->
      expect(team.label()).to.be.equal("`junior` team")

  describe "#addPlayer", ->
    it "should insert new team player", ->
      team.addPlayer("Chalien")
      expect(team.players().length).to.be.equal(1)

  describe "#size", ->
    it "should count all the players added to the team", ->
      team.addPlayer(player) for player in ["peter", "sack"]
      expect(team.size()).to.be.equal(2)



