import Transmitter from 'transmitter';


describe('Merging after splitting', function() {

  before(function() {
    this.define('keypressVar', new Transmitter.Nodes.SourceNode());
    this.define('stateVar', new Transmitter.Nodes.Variable());

    this.stateVar.set(false);

    Transmitter.startTransmission( (tr) => {
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.keypressVar)
        .toTarget(this.stateVar)
        .withTransform( (keypress) =>
          keypress.noopIf( (key) => key !== 'enter' ).map( () => true )
        )
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.keypressVar)
        .toTarget(this.stateVar)
        .withTransform( (keypress) =>
          keypress.noopIf( (key) => key !== 'esc' ).map( () => false )
        )
        .init(tr);
    });
  });


  specify('splitted message is merged correctly', function() {
    Transmitter.startTransmission( (tr) =>
      this.keypressVar.originate(tr, 'enter')
    );

    expect(this.stateVar.get()).to.equal(true);
  });


  specify('...independent of order', function() {
    Transmitter.startTransmission( (tr) =>
      this.keypressVar.originate(tr, 'esc')
    );

    expect(this.stateVar.get()).to.equal(false);
  });
});
