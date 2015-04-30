expect         = require('chai').expect
UserNormalizer = require '../../src/helpers/user_normalizer'

describe 'UserNormalizer', ->

  describe '.normalizationEnabled', ->
    describe 'HUBOT_TEAM_NORMALIZE_USERNAMES env var is set', ->
      before ->
        process.env.HUBOT_TEAM_NORMALIZE_USERNAMES = true

      after ->
        delete process.env.HUBOT_TEAM_NORMALIZE_USERNAMES

       it 'is enabled', ->
        expect(UserNormalizer.normalizationEnabled()).to.be.true

    describe 'HUBOT_TEAM_NORMALIZE_USERNAMES env var is not set', ->
       it 'is not enabled', ->
        expect(UserNormalizer.normalizationEnabled()).to.be.false

  describe '.normalize', ->
    result = null

    describe 'normalization is enabled', ->
      before ->
        process.env.HUBOT_TEAM_NORMALIZE_USERNAMES = true

      after ->
        delete process.env.HUBOT_TEAM_NORMALIZE_USERNAMES

      describe 'userInput is given', ->

        describe 'when contains @', ->
          beforeEach ->
            result = UserNormalizer.normalize('mocha', '@junior@')

          it 'removes all @ and add @ to the begining of userInput', ->
            expect(result).to.equal('@junior')

        describe 'when does not contain @', ->
          beforeEach ->
            result = UserNormalizer.normalize('mocha', 'junior')

          it 'adds @ to the begining of userInput', ->
            expect(result).to.equal('@junior')

        describe 'when is "me"', ->
          beforeEach ->
            result = UserNormalizer.normalize('mocha', 'me')

          it 'adds @ to the begining of username', ->
            expect(result).to.equal('@mocha')

      describe 'userInput is not given', ->
        beforeEach ->
          result = UserNormalizer.normalize('mocha')

        it 'adds @ to the begining of username', ->
          expect(result).to.equal('@mocha')

    describe 'normalization is disabled', ->
      describe 'userInput is given', ->
        beforeEach ->
          result = UserNormalizer.normalize('mocha', 'junior')

        it 'returns the user input', ->
            expect(result).to.equal('junior')

        describe 'when is "me"', ->
            beforeEach ->
              result = UserNormalizer.normalize('mocha', 'me')

            it 'returns the username', ->
              expect(result).to.equal('mocha')

      describe 'userInput is not given', ->
        beforeEach ->
          result = UserNormalizer.normalize('mocha')

        it 'returns the username', ->
          expect(result).to.equal('mocha')
