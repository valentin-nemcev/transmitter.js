'use strict'


BindingBuilder = require 'binder/binding/builder'


describe 'BindingBuilder', ->

  createdBinding = null
  bindingConstructor = null

  beforeEach ->
    createdBinding = new class BindingStub
      bindSourceTarget: sinon.spy()

    bindingConstructor = sinon.stub().returns(createdBinding)


  describe 'when building binding with simple source', ->

    it 'should create and bind binding with given source and target', ->
      source = new class SourceStub
      target = new class TargetStub
      new BindingBuilder({bindingConstructor})
        .fromSource(source)
        .toTarget(target)
        .bind()

      expect(createdBinding.bindSourceTarget)
        .to.have.been.calledWith(source, target)


  describe 'with transform function', ->

    it 'should pass transform function to binding constructor', ->
      transform = ->

      new BindingBuilder({bindingConstructor})
        .withTransform transform
        .bind()

      expect(bindingConstructor).to.have.been.calledWith({transform})


    it 'should pass id function as transform by default', ->

      new BindingBuilder({bindingConstructor}).bind()

      defaultTransform = bindingConstructor.firstCall.args[0].transform
      arg = {}
      expect(defaultTransform(arg)).to.equal(arg)


  describe 'when building binding with composite source', ->

    target = null
    buildCompositeSource = null
    compositeSourceBuilder = null
    createdCompositeSource = null

    beforeEach ->
      target = new class TargetStub
      compositeSourceBuilder = new class CompositeSourceBuilderStub
      createdCompositeSource = new class CompositeSourceStub
      compositeSourceBuilder.create =
        sinon.stub().returns(createdCompositeSource)
      buildCompositeSource = sinon.stub().returns(compositeSourceBuilder)


    it 'should delegate to composite source builder', ->
      defineCompositeSource = sinon.spy()
      new BindingBuilder({bindingConstructor, buildCompositeSource})
        .fromCompositeSource defineCompositeSource
        .toTarget(target)
        .bind()

      expect(defineCompositeSource)
        .to.have.been.calledWith(compositeSourceBuilder)


    it 'should pass created composite source to binding', ->
      new BindingBuilder({bindingConstructor, buildCompositeSource})
        .fromCompositeSource( -> )
        .toTarget(target)
        .bind()

      expect(createdBinding.bindSourceTarget)
        .to.have.been.calledWith(createdCompositeSource, target)
