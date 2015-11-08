import * as Transmitter from 'transmitter';


describe('Merging after splitting', function() {

  before(function() {
    this.define('keypressValue', new Transmitter.Nodes.ValueSource());
    this.define('stateValue', new Transmitter.Nodes.Value());

    this.stateValue.set(false);

    Transmitter.startTransmission( (tr) => {
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.keypressValue)
        .toTarget(this.stateValue)
        .withTransform( (keypress) =>
          keypress.noopIf( (key) => key !== 'enter' ).map( () => true )
        )
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.keypressValue)
        .toTarget(this.stateValue)
        .withTransform( (keypress) =>
          keypress.noopIf( (key) => key !== 'esc' ).map( () => false )
        )
        .init(tr);
    });
  });


  specify('splitted message is merged correctly', function() {
    Transmitter.startTransmission( (tr) =>
      this.keypressValue.originateValue(tr, 'enter')
    );

    expect(this.stateValue.get()).to.equal(true);
  });


  specify('...independent of order', function() {
    Transmitter.startTransmission( (tr) =>
      this.keypressValue.originateValue(tr, 'esc')
    );

    expect(this.stateValue.get()).to.equal(false);
  });
});
