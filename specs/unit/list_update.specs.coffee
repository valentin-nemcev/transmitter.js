'use strict'

sinon = require 'sinon'
{assert} = require 'chai'


ListPayload = require 'transmitter/payloads/list'
List = require 'transmitter/nodes/list'



describe 'List update', ->

  beforeEach ->
    id = (a) -> a
    equals = (a, b) -> a == b

    @target = new List()
    @updateTarget = (list) =>
      new ListPayload.createFromValue(list).mapIfMatch(id, equals)
        .deliver(@target)

    @added   = sinon.spy(@target, 'addAt')
    @removed = sinon.spy(@target, 'removeAt')
    @moved   = sinon.spy(@target, 'move')


  specify 'Set different elements', ->
    # Setup
    @target.set ['element1', 'element2', 'element3']

    # Excercise
    @updateTarget(['new element1', 'new element2'])

    # Verify
    assert.deepEqual(@target.get(), ['new element1', 'new element2'])

    assert.equal(@removed.callCount, 3)
    assert.equal(@added.callCount, 2)
    assert.equal(@moved.callCount, 0)



  specify 'Set same elements', ->
    # Setup
    @target.set ['element1', 'element2', 'element3']

    # Excercise
    @updateTarget(['element1', 'element2', 'element3'])

    # Verify
    assert.deepEqual(@target.get(), ['element1', 'element2', 'element3'])

    assert.equal(@added.callCount, 0)
    assert.equal(@removed.callCount, 0)
    assert.equal(@moved.callCount, 0)



  specify 'Set changed elements', ->
    # Setup
    @target.set [4, 2, 5, 3]

    # Excercise
    @updateTarget([0, 1, 2, 3, 4])

    # Verify
    assert.deepEqual(@target.get(), [0, 1, 2, 3, 4])

    assert.equal(@added.callCount, 2)
    assert.equal(@removed.callCount, 1)
    assert.equal(@moved.callCount, 2)



  specify 'Set repeating elements', ->
    # Setup
    @target.set [4, 4, 2, 5, 3, 2]

    # Excercise
    @updateTarget([2, 2, 1, 4, 2, 4])

    # Verify
    assert.deepEqual(@target.get(), [2, 2, 1, 4, 2, 4])
