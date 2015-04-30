expect = require('chai').expect
Team   = require '../../src/models/team'

describe 'Team', ->
  beforeEach ->
    Team.robot = {brain: {data: {}}}

  describe 'class methods', ->
    describe '.store', ->
      it 'gets the store', ->
        teams = {test: {name: 'test', members: []}}
        Team.robot.brain.data.teams = teams
        expect(Team.store()).to.eql(teams)

      describe 'storage is not initialized', ->
        it 'initializes', ->
          expect(Team.store()).to.eql({})

      describe 'robot is not defined', ->
        it 'throws an error', ->
          Team.robot = null
          expect(Team.store).to.throw(/robot is not set up/)

    describe '.defaultName', ->
      it 'return the default team name', ->
        expect(Team.defaultName()).to.eql('__default__')

    describe '.all', ->
      it 'returns an array with the teams', ->
        Team.create('team1')
        teams = Team.all()
        expect(teams[0].name).to.eql('team1')

      describe 'store contains the default team', ->
        it 'excludes the default team', ->
          Team.create('team1')
          Team.getDefault()
          teams = Team.all()
          expect(teams.length).to.eql(1)

      describe 'store is empty', ->
        it 'returns an empty array', ->
          expect(Team.all()).to.eql([])

    describe '.getDefault', ->
      describe 'default team already exist', ->
        it 'returns the default team', ->
          expect(Team.getDefault().isDefault()).to.be.true

      describe 'default team does not exist', ->
        it 'saves the default team in the store', ->
          expect(Team.store()).to.not.include.keys('__default__')
          Team.getDefault()
          expect(Team.store()).to.include.keys('__default__')

    describe '.count', ->
      it 'returns the exact count', ->
        Team.store()['team1'] =
          name: 'team1'
          members: []
        expect(Team.count()).to.eql(1)

      describe 'store is empty', ->
        it 'returns zero', ->
          expect(Team.count()).to.eql(0)

    describe '.get', ->
      it 'returns the matching team', ->
        Team.store()['team1'] =
          name: 'team1'
          members: ['member1']
        team = Team.get('team1')
        expect(team.name).to.eql('team1')
        expect(team.members).to.eql(['member1'])

      describe 'store has no matching data', ->
        it 'returns null', ->
          expect(Team.get('team1')).to.be.null

      describe 'name not given', ->
        it 'returns null', ->
          expect(Team.get()).to.be.null

    describe '.getOrDefault', ->
      describe 'teamName is given', ->
        it 'finds a team', ->
          Team.create 'team1'
          team = Team.getOrDefault('team1')
          expect(team.name).to.eql('team1')

        describe 'store has no matching data', ->
          it 'returns null', ->
            expect(Team.getOrDefault('team1')).to.be.null

      describe 'teamName is not given', ->
        it 'returns the default team', ->
          expect(Team.getOrDefault().isDefault()).to.be.true

    describe '.exists', ->
      describe 'store has matching data', ->
        it 'returns true', ->
          Team.store()['team1'] =
            name: 'team1'
            members: []
          expect(Team.exists('team1')).to.be.true

      describe 'store has no matching data', ->
        it 'returns false', ->
          expect(Team.exists('team1')).to.be.false

    describe '.create', ->
      it 'saves the team in the store', ->
        Team.create('team1')
        expect(Team.store()).to.include.keys('team1')

      it 'returns a new team', ->
        team = Team.create('team1')
        expect(team.name).to.eql('team1')

      describe 'store contains a team with the same name', ->
        it 'returns false', ->
          Team.store()['team1'] =
          name: 'team1'
          members: []
          expect(Team.create('team1')).to.be.false

  describe 'instance methods', ->
    describe '#constructor', ->
      it 'stores the name', ->
        team = new Team('team1', [])
        expect(team.name).to.eql('team1')

      it 'stores the members', ->
        team = new Team('team1', [])
        expect(team.members).to.eql([])

      describe 'name is not given', ->
        it 'assigns the default team name', ->
          team = new Team()
          expect(team.name).to.eql('__default__')

      describe 'members is not given', ->
        it 'assigns an empty array', ->
          team = new Team()
          expect(team.members).to.eql([])

    describe '#addMember', ->
      team = null

      beforeEach ->
        team = Team.create('team1')
        team.addMember('@member1')

      it 'adds the member to the local collection', ->
        expect(team.members).to.include('@member1')

      it 'adds 1 member to the collection', ->
        expect(team.members).to.have.length(1)

      it 'adds the member to the store', ->
        members = Team.store()['team1'].members
        expect(members).to.include('@member1')

      it 'returns true', ->
        expect(team.addMember('@member2')).to.be.true

      describe 'member already exists', ->
        it 'returns false', ->
          expect(team.addMember('@member1')).to.be.false

    describe '#removeMember', ->
      it 'removes the member from the local collection', ->
        team = Team.create('team1', ['member1'])
        team.removeMember('member1')
        expect(team.members).to.eql([])

      it 'removes the member from the store', ->
        team = Team.create('team1', ['member1'])
        team.removeMember('member1')
        expect(Team.store()['team1'].members).to.eql([])

      describe 'member does not exist', ->
        it 'returns false', ->
          team = Team.create('team1')
          expect(team.removeMember('member1')).to.be.false

    describe '#membersCount', ->
      it 'returns the quantity of members in the team', ->
        team = Team.create('team1', ['@member1', '@member2'])
        expect(team.membersCount()).to.eql(2)

    describe '#clear', ->
      team = null
      beforeEach ->
        team = Team.create('team1', ['@member1'])

      it 'removes all members from the local collection', ->
        team.clear()
        expect(team.members).to.eql([])

      it 'removes all members from the store', ->
        team.clear()
        expect(Team.store()['team1'].members).to.eql([])

    describe '#destroy', ->
      team = null
      beforeEach ->
        team = Team.create('team1')

      it 'removes the team from the store', ->
        team.destroy()
        expect(Team.store()).to.not.include.keys('team1')

    describe '#label', ->
      it 'returns the team label', ->
        team = new Team('team1')
        expect(team.label()).to.eql('`team1` team')

      describe 'if default team', ->
        it 'returns the default label', ->
          team = new Team()
          expect(team.label()).to.eql('team')

    describe '#isDefault', ->
      describe 'name is the default team label', ->
        it 'returns true', ->
          team = new Team()
          expect(team.isDefault()).to.be.true

      describe 'name is not the default team label', ->
        it 'returns false', ->
          team = new Team('team1')
          expect(team.isDefault()).to.be.false
