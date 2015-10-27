/* eslint-env mocha, chai */
/* global expect */
/* eslint-disable padded-blocks */

import Transmitter from 'transmitter';

class Model {
  inspect() { return '[Model ' + this.name + ']'; }

  constructor(name) {
    this.name = name;
    this.valueVar = new Transmitter.Nodes.Variable();
  }
}

class View {
  inspect() { return '[View ' + this.model.name + ']'; }

  constructor(model) {
    this.model = model;
    this.removeEvt = new Transmitter.Nodes.SourceNode();
    this.valueVar = new Transmitter.Nodes.Variable();
  }
}


describe('Flattening with nested list connections', function() {

  before(function() {
    this.define('originList', new Transmitter.Nodes.List());
    this.define('derivedList', new Transmitter.Nodes.List());

    const originDerivedChannel = new Transmitter.Channels.ListChannel()
      .withOrigin(this.originList)
      .withDerived(this.derivedList)
      .withMapOrigin( (model) => new View(model) )
      .withMatchOriginDerived( (model, view) => model === view.model )
      .withMatchOriginDerived( (model, view) => model === view.model )
      .withOriginDerivedChannel( (model, view) =>
        new Transmitter.Channels.VariableChannel()
          .withOrigin(model.valueVar)
          .withDerived(view.valueVar)
      )
      .withMatchOriginDerivedChannel( (model, view, channel) =>
        channel.origin === model && channel.derived === view
      );

    this.define(
      'flatteningChannelList',
      new Transmitter.ChannelNodes.ChannelList()
    );

    const flatteningChannel = new Transmitter.Channels.SimpleChannel()
      .fromSource(this.derivedList)
      .toConnectionTarget(this.flatteningChannelList)
      .withTransform( (viewList) =>
          viewList.map( (view) =>
            new Transmitter.Channels.SimpleChannel()
            .inBackwardDirection()
            .fromSource(view.removeEvt)
            .toTarget(this.originList)
            .withTransform( (ev) =>
               ev.map( () => view.model ).toRemoveListElement()
            )
          )
      );

    Transmitter.startTransmission( (tr) => {
      originDerivedChannel.init(tr);
      flatteningChannel.init(tr);
      this.model1 = new Model('model1');
      this.model2 = new Model('model2');
      this.model1.valueVar.init(tr, 'value1');
      this.model2.valueVar.init(tr, 'value2');
      this.originList.init(tr, [this.model1, this.model2]);
    });
  });


  specify('when derived nested node originates update', function() {
    Transmitter.startTransmission( (tr) =>
        this.derivedList.getAt(0).removeEvt.originate(tr, true)
    );
  });


  specify('then it propagates to origin node', function() {
    expect(this.originList.get()).to.have.members([this.model2]);
  });


  specify('when derived nested node is updated', function() {
    Transmitter.startTransmission( (tr) =>
      this.derivedList.getAt(0).valueVar.init(tr, 'value2a')
    );
  });


  specify('then update is transmitted to derived nested node', function() {
    expect(this.originList.get().map( (model) => model.valueVar.get() ))
      .to.deep.equal(['value2a']);
  });
});
