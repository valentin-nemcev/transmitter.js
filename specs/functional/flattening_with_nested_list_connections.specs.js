import * as Transmitter from 'transmitter';

class Model {
  inspect() { return '[Model ' + this.name + ']'; }

  constructor(name) {
    this.name = name;
    this.valueNode = new Transmitter.Nodes.ValueNode();
  }
}

class View {
  inspect() { return '[View ' + this.model.name + ']'; }

  constructor(model) {
    this.model = model;
    this.removeEvt = new Transmitter.Nodes.ValueSourceNode();
    this.valueNode = new Transmitter.Nodes.ValueNode();
  }
}


describe('Flattening with nested list connections', function() {

  function id(arg) { return arg; }

  before(function() {
    this.define('modelList', new Transmitter.Nodes.OrderedSetNode());
    this.define('viewMap', new Transmitter.Nodes.OrderedMapNode());

    const originDerivedChannel =
      new Transmitter.Channels.NestedBidirectionalChannel()
        .inForwardDirection()
        .withOriginDerived(this.modelList, this.viewMap)
        .useSetToMapUpdate()
        .withMapOrigin( (model) => new View(model) )
        .withOriginDerivedChannel( (model, view) =>
          new Transmitter.Channels.BidirectionalChannel()
            .inBothDirections()
            .withOriginDerived(model.valueNode, view.valueNode)
            .withMapOrigin(id)
            .withMapDerived(id)
        );

    this.define(
      'flatteningChannelList',
      new Transmitter.ChannelNodes.ChannelList()
    );

    const flatteningChannel = new Transmitter.Channels.NestedSimpleChannel()
      .fromSource(this.viewMap)
      .toChannelTarget(this.flatteningChannelList)
      .withTransform( (viewMap) =>
          viewMap.map( (view) =>
            new Transmitter.Channels.SimpleChannel()
            .inBackwardDirection()
            .fromSource(view.removeEvt)
            .toTarget(this.modelList)
            .withTransform( (ev) =>
               ev.map( () => view.model ).toRemoveAction()
            )
          )
      );

    Transmitter.startTransmission( (tr) => {
      originDerivedChannel.init(tr);
      flatteningChannel.init(tr);
      this.model1 = new Model('model1');
      this.model2 = new Model('model2');
      this.model1.valueNode.set('value1').init(tr);
      this.model2.valueNode.set('value2').init(tr);
      this.modelList.set([this.model1, this.model2]).init(tr);
    });
  });


  specify('when derived nested node originates update', function() {
    Transmitter.startTransmission( (tr) =>
        this.viewMap.get()[0][1].removeEvt.originateValue(tr, true)
    );
  });


  specify('then it propagates to origin node', function() {
    expect(this.modelList.get()).to.have.members([this.model2]);
  });


  specify('when derived nested node is updated', function() {
    Transmitter.startTransmission( (tr) =>
      this.viewMap.get()[0][1].valueNode.set('value2a').init(tr)
    );
  });


  specify('then update is transmitted to derived nested node', function() {
    expect(this.modelList.get().map( (model) => model.valueNode.get() ))
      .to.deep.equal(['value2a']);
  });
});
