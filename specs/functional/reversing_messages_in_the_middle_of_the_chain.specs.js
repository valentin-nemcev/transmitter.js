import * as Transmitter from 'transmitter';

describe('Reversing messages in the middle of the chain', function() {

  before(function() {
    this.define('button', new Transmitter.Nodes.ValueSourceNode());
    this.define('textInput', new Transmitter.Nodes.ValueNode());
    this.define('tagList', new Transmitter.Nodes.ListNode());

    Transmitter.startTransmission( (tr) => {
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSources(this.button, this.textInput)
        .toTarget(this.tagList)
        .withTransform( ([buttonWasClickedPayload, textValuePayload]) =>
          textValuePayload.replaceByNoOp(buttonWasClickedPayload)
            .toAppendAction()
        )
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inForwardDirection()
        .fromSource(this.button)
        .toTarget(this.textInput)
        .withTransform( (buttonWasClickedPayload) =>
          buttonWasClickedPayload.map( () => '' )
        )
        .init(tr);

      this.tagList.set(['value 1']).init(tr);
      this.textInput.set('value 2').init(tr);
    });
  });


  specify('when button is clicked', function() {
    Transmitter.startTransmission( (tr) =>
      this.button.originateValue(tr, 'click')
    );
  });


  specify('text input value should be added to list', function() {
    expect(this.tagList.get()).to.deep.equal(['value 1', 'value 2']);
  });


  specify('text input value should cleared', function() {
    expect(this.textInput.get()).to.equal('');
  });
});
