chai           = require 'chai'
expect         = chai.expect
UserNormalizer = require '../../src/helpers/user_normalizer'

describe 'UserNormalizer', ->

  describe '#normalize', ->
    result = null

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

      describe 'when is \'me\'', ->
        beforeEach ->
          result = UserNormalizer.normalize('mocha', 'me')

        it 'adds @ to the begining of username', ->
          expect(result).to.equal('@mocha')

    describe 'userInput is not given', ->
      beforeEach ->
        result = UserNormalizer.normalize('mocha')

      it 'adds @ to the begining of username', ->
        expect(result).to.equal('@mocha')
