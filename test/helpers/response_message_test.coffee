expect          = require('chai').expect
responseMessage = require '../../src/helpers/response_message'
Team            = require '../../src/models/team'

describe 'ResponseMessage', ->
  beforeEach ->
    Team.robot = {brain: {data: {}}}

  describe '#teamCreated', ->
    it 'returns the message', ->
      team = new Team('team1')
      expect(responseMessage.teamCreated(team)).to.eql('`team1` team created, add some people to it')

  describe '#teamAlreadyExists', ->
    it 'returns the message', ->
      team = Team.create('team1')
      expect(responseMessage.teamAlreadyExists(team)).to.eql('`team1` team already exists')

  describe '#teamDeleted', ->
    it 'returns the message', ->
      team = Team.create('team1')
      expect(responseMessage.teamDeleted(team)).to.eql('`team1` team removed')

  describe '#listTeams', ->
    describe 'teams with members', ->
      it 'includes members and total', ->
        Team.create('team1', ['@member1', '@member2'])
        teams = Team.all()
        expected = 'Teams:\n`team1` (2 total)\n- @member1\n- @member2'
        expect(responseMessage.listTeams(teams)).to.eql(expected)

    describe 'without members', ->
      it 'does not include members', ->
        Team.create('team1')
        Team.create('team2')
        teams = Team.all()
        expected = 'Teams:\n`team1` (empty)\n`team2` (empty)\n'
        expect(responseMessage.listTeams(teams)).to.eql(expected)

  describe '#adminRequired', ->
    it 'returns the message', ->
      expect(responseMessage.adminRequired()).to.eql('Sorry, only admins can perform this operation')

  describe '#memberAddedToTeam', ->
    describe 'there is no members in the team', ->
      it 'returns the message', ->
        team = new Team('team1', ['member1'])
        expect(responseMessage.memberAddedToTeam('member1', team)).to.eql('member1 added to the `team1` team')

    describe 'there is one member in the team', ->
      it 'returns the message', ->
        team = new Team('team1', ['member1', 'member2'])
        expect(responseMessage.memberAddedToTeam('member2', team)).to.eql('member2 added to the `team1` team, 1 other is in')

    describe 'there are two members in the team', ->
      it 'returns the message', ->
        team = new Team('team1', ['member1', 'member2', 'member3'])
        expect(responseMessage.memberAddedToTeam('member3', team)).to.eql('member3 added to the `team1` team, 2 others are in')

  describe '#memberAlreadyAddedToTeam', ->
    it 'returns the message', ->
      team = new Team('team1')
      expect(responseMessage.memberAlreadyAddedToTeam('member1', team)).to.eql('member1 already in the `team1` team')

  describe '#memberRemovedFromTeam', ->
    describe 'there is one member', ->
      it 'returns the message', ->
        team = new Team('team1', [])
        expect(responseMessage.memberRemovedFromTeam('member1', team)).to.eql('member1 removed from the `team1` team')

    describe 'there are some members', ->
      it 'returns the message', ->
        team = new Team('team1', ['member1'])
        expect(responseMessage.memberRemovedFromTeam('member2', team)).to.eql('member2 removed from the `team1` team, 1 remaining')

  describe '#memberAlreadyOutOfTeam', ->
    it 'returns the message', ->
      team = new Team('team1')
      expect(responseMessage.memberAlreadyOutOfTeam('member1', team)).to.eql('member1 already out of the `team1` team')

  describe '#teamCount', ->
    it 'returns the message', ->
      team = new Team('soccer', ['@mocha', '@peter'])
      expect(responseMessage.teamCount(team)).to.eql('2 people are currently in the team')

  describe '#teamNotFound', ->
    it 'returns the message', ->
      expect(responseMessage.teamNotFound('team1')).to.eql('`team1` team does not exist')

  describe '#listTeam', ->
    describe 'with members', ->
      it 'returns the message', ->
        team = Team.create('team1', ['@member2', '@member2'])
        expected = '`team1` team (2 total):\n1. @member2\n2. @member2\n'
        expect(responseMessage.listTeam(team)).to.eql(expected)

    describe 'without members', ->
      it 'returns the message', ->
        team = Team.create('team1')
        expected = 'There is no one in the `team1` team currently'
        expect(responseMessage.listTeam(team)).to.eql(expected)

  describe '#teamCleared', ->
    it 'returns the message', ->
      team = Team.create('soccer')
      expect(responseMessage.teamCleared(team)).to.eql("`soccer` team list cleared")

    describe 'default team', ->
      it 'returns the message', ->
        team = Team.getDefault()
        expect(responseMessage.teamCleared(team)).to.eql("team list cleared")
