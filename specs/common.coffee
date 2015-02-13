'use strict'


chai = require 'chai'
global.expect = chai.expect

global.sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai
