'use strict'


Query = require 'binder/query'


class MessageChainStub

class MessageReceiverStub
  enquire: ->


describe 'Query', ->

  beforeEach ->
    @messageChain = new MessageChainStub()
    @query = new Query(@messageChain)


  describe 'when enquired target node', ->

    beforeEach ->
      @targetMessageReceiver = new MessageReceiverStub
      @targetNode = {getMessageReceiver: => @targetMessageReceiver}


    it 'should enquire node message target', ->
      sinon.spy(@targetMessageReceiver, 'enquire')
      @query.enquireTarget(@targetNode)

      expect(@targetMessageReceiver.enquire)
        .to.have.been.calledWithSame(@query)


