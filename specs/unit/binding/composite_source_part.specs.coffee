'use strict'



CompositeBindingSourcePart = require 'binder/binding/composite_source_part'


describe 'CompositeBindingSourcePart', ->

  beforeEach ->
    @source = {}
    @part = new CompositeBindingSourcePart(@source)


  it 'should provide its source as a key', ->
    expect(@part.getSourceKey()).to.equal(@source)


