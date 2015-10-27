import Transmitter from 'transmitter';

class AlertEmitter extends Transmitter.Nodes.TargetNode {
  alert() {}

  acceptPayload(payload) {
    payload.deliverValue(this);
    return this;
  }

  receiveValue(messageStr) {
    if (messageStr != null) {
      return this.alert(messageStr);
    }
  }
}


describe('Connection with merge and query', function() {

  beforeEach(function() {
    this.define('button', new Transmitter.Nodes.SourceNode());
    this.define('textInput', new Transmitter.Nodes.Variable());
    this.define('alertEmitter', new AlertEmitter());
    sinon.spy(this.alertEmitter, 'alert');

    Transmitter.startTransmission( (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .fromSource(this.button)
        .fromSource(this.textInput)
        .inBackwardDirection()
        .withTransform( ([buttonWasClickedPayload, textValuePayload]) =>
          textValuePayload.replaceByNoop(buttonWasClickedPayload)
        )
        .toTarget(this.alertEmitter)
        .init(tr)
    );
  });


  it('should emit alert with text input value when button is clicked',
  function() {
    Transmitter.startTransmission( (tr) =>
      this.textInput.init(tr, 'Text input value')
    );
    Transmitter.startTransmission( (tr) =>
      this.button.originate(tr, 'click')
    );
    expect(this.alertEmitter.alert)
      .to.have.been.calledWith('Text input value');
  });


  it('should not emit alert when button is not clicked', function() {
    Transmitter.startTransmission( (tr) =>
      this.textInput.init(tr, 'Text input value')
    );
    expect(this.alertEmitter.alert).to.not.have.been.called();
  });
});
