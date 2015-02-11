'use strict'

{assert} = require 'chai'

binder = require 'binder'
binderExample = require 'binder/example'

describe 'Binder', ->
  describe 'example', ->
    it 'should require binder module', ->
      assert.equal('test', binder.example.str)
      assert.equal('test', binderExample.str)
