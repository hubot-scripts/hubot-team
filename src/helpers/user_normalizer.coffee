class UserNormalizer
  @normalize: (username, userInput)->
    if not userInput? or (userInput?.toLocaleLowerCase() is 'me')
      return '@' + username
    '@' + userInput.replace /@*/g, ''

module.exports = UserNormalizer
