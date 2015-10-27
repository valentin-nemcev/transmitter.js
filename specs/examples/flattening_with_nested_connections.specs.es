import Transmitter from 'transmitter';

class Model {
  inspect() { return '[Model]'; }
}

class View {
  inspect() { return '[View]'; }

  constructor(model) {
    this.model = model;
    this.removeEvt = new Transmitter.Nodes.SourceNode();
  }
}


describe('Flattening with nested connections', function() {

  before(function() {
    this.define('derivedVar', new Transmitter.Nodes.Variable());
    this.define('originVar', new Transmitter.Nodes.Variable());

    const originDerivedChannel = new Transmitter.Channels.VariableChannel()
    .withOrigin(this.originVar)
    .withDerived(this.derivedVar)
    .withMapOrigin(function(model) {
      return new View(model);
    })
    .withMatchOriginDerived(function(model, view) {
      return model === view.model;
    });

    this.define(
      'flatteningChannelVar',
      new Transmitter.ChannelNodes.ChannelVariable()
    );

    const flatteningChannel = new Transmitter.Channels.SimpleChannel()
    .fromSource(this.derivedVar)
    .toConnectionTarget(this.flatteningChannelVar)
    .withTransform( (viewVal) =>
      viewVal.map( (view) => {
        if (view != null) {
          return new Transmitter.Channels.SimpleChannel()
            .inBackwardDirection()
            .fromSource(view.removeEvt)
            .toTarget(this.originVar)
            .withTransform( (ev) => ev.map( () => null ) );
        } else {
          return Transmitter.Channels.getNullChannel();
        }
      })
    );

    Transmitter.startTransmission( (tr) => {
      originDerivedChannel.init(tr);
      flatteningChannel.init(tr);
      this.originVar.init(tr, new Model());
    });
  });


  specify('when derived nested node originates update', function() {
    Transmitter.startTransmission( (tr) =>
      this.derivedVar.get().removeEvt.originate(tr, true)
    );
  });


  specify('then it propagates to origin node', function() {
    expect(this.originVar.get()).to.be.null();
  });


  specify('and it propagates back to derived node', function() {
    expect(this.derivedVar.get()).to.be.null();
  });


  describe('with loop', function() {

    before(function() {
      this.define('supOriginVar', new Transmitter.Nodes.Variable());

      const supOriginChannel = new Transmitter.Channels.VariableChannel()
        .withOrigin(this.supOriginVar)
        .withDerived(this.originVar);

      Transmitter.startTransmission( (tr) =>
        supOriginChannel.init(tr)
      );
    });


    specify('when super origin is updated', function() {
      Transmitter.startTransmission( (tr) => {
        this.model = new Model();
        this.originVar.init(tr, this.model);
      });
    });


    specify('then it propagates to derived node', function() {
      expect(this.derivedVar.get().model).to.equal(this.model);
    });
  });
});
