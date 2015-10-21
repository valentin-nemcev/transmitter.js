'use strict'

require('source-map-support').install()

require('babel/register')({
  only: '*.es'
})

Error.stackTraceLimit = 5

chai = require 'chai'
global.expect = chai.expect

global.sinon = require 'sinon'
require 'mocha-sinon'

sinonChai = require 'sinon-chai'
chai.use sinonChai

chai.use (chai, util) ->
  {Assertion} = chai
  Assertion.addMethod('calledWithSame', ->
    @calledWith(global.sinon.match.same(arguments...))
  )
