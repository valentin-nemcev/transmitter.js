import * as Transmitter from 'transmitter';

class AlertEmitter extends Transmitter.Nodes.TargetNode {
  alert() {}

  set(messageStr) {
    if (messageStr != null) {
      return this.alert(messageStr);
    }
  }

  setIterator(it) {
    const {value: entry} = it[Symbol.iterator]().next();
    this.set(entry[1]);
    return this;
  }
}


describe('Connection with merge and query', function() {

  beforeEach(function() {
    this.define('button', new Transmitter.Nodes.ValueSource());
    this.define('textInput', new Transmitter.Nodes.Value());
    this.define('alertEmitter', new AlertEmitter());
    sinon.spy(this.alertEmitter, 'alert');

    Transmitter.startTransmission( (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSources(this.button, this.textInput)
        .toTarget(this.alertEmitter)
        .withTransform( ([buttonWasClickedPayload, textValuePayload]) =>
          textValuePayload.replaceByNoOp(buttonWasClickedPayload)
        )
        .init(tr)
    );
  });


  it('should emit alert with text input value when button is clicked',
  function() {
    Transmitter.startTransmission( (tr) =>
      this.textInput.set('Text input value').init(tr)
    );
    Transmitter.startTransmission( (tr) =>
      this.button.originateValue(tr, 'click')
    );
    expect(this.alertEmitter.alert)
      .to.have.been.calledWith('Text input value');
  });


  it('should not emit alert when button is not clicked', function() {
    Transmitter.startTransmission( (tr) =>
      this.textInput.set('Text input value').init(tr)
    );
    expect(this.alertEmitter.alert).to.not.have.been.called();
  });
});
