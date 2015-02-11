'use strict'

assert = require 'assert'

binder = require 'binder'
binderExample = require 'binder/example'

describe 'Binder', ->
  describe 'example', ->
    it 'should require binder module', ->
      assert.equal('test', binder.example.str)
      assert.equal('test', binderExample.str)
