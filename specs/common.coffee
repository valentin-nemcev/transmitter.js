'use strict'

require 'es6-shim'

Error.stackTraceLimit = 3

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
