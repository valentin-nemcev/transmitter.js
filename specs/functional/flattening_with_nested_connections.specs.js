import * as Transmitter from 'transmitter';

class Model {
  inspect() { return '[Model]'; }
}

class View {
  inspect() { return '[View]'; }

  constructor(model) {
    this.model = model;
    this.removeEvt = new Transmitter.Nodes.ValueSource();
  }
}


describe('Flattening with nested connections', function() {

  before(function() {
    this.define('derivedValue', new Transmitter.Nodes.Optional());
    this.define('originValue', new Transmitter.Nodes.Optional());

    const originDerivedChannel =
      new Transmitter.Channels.BidirectionalChannel()
      .inForwardDirection()
      .withOriginDerived(this.originValue, this.derivedValue)
      .withMatchOriginDerived(function(model, view) {
        return model === view.model;
      })
      .withMapOrigin(function(model) {
        return new View(model);
      });

    this.define(
      'flatteningChannelValue',
      new Transmitter.ChannelNodes.ChannelValue()
    );

    const flatteningChannel = new Transmitter.Channels.NestedSimpleChannel()
      .fromSource(this.derivedValue)
      .toChannelTarget(this.flatteningChannelValue)
      .withTransform( (viewVal) =>
        viewVal.map( (view) => {
          return new Transmitter.Channels.SimpleChannel()
            .inBackwardDirection()
            .fromSource(view.removeEvt)
            .toTarget(this.originValue)
            .withTransform( (ev) => ev.map( () => null ) );
        })
      );

    Transmitter.startTransmission( (tr) => {
      originDerivedChannel.init(tr);
      flatteningChannel.init(tr);
      this.originValue.set(new Model()).init(tr);
    });
  });


  specify('when derived nested node originates update', function() {
    Transmitter.startTransmission( (tr) =>
      this.derivedValue.get().removeEvt.originateValue(tr, true)
    );
  });


  specify('then it propagates to origin node', function() {
    expect(this.originValue.get()).to.be.null();
  });


  specify('and it propagates back to derived node', function() {
    expect(this.derivedValue.get()).to.be.null();
  });


  describe('with loop', function() {

    function id(arg) { return arg; }

    before(function() {
      this.define('supOriginValue', new Transmitter.Nodes.Value());

      const supOriginChannel = new Transmitter.Channels.BidirectionalChannel()
        .inBothDirections()
        .withOriginDerived(this.supOriginValue, this.originValue)
        .withMapOrigin(id)
        .withMapDerived(id);

      Transmitter.startTransmission( (tr) =>
        supOriginChannel.init(tr)
      );
    });


    specify('when super origin is updated', function() {
      Transmitter.startTransmission( (tr) => {
        this.model = new Model();
        this.originValue.set(this.model).init(tr);
      });
    });


    specify('then it propagates to derived node', function() {
      expect(this.derivedValue.get().model).to.equal(this.model);
    });
  });
});
