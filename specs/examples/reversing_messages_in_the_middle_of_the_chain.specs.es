/* eslint-env mocha, chai */
/* global expect */
/* eslint-disable padded-blocks */

import Transmitter from 'transmitter';

describe('Reversing messages in the middle of the chain', function() {

  before(function() {
    this.define('button', new Transmitter.Nodes.SourceNode());
    this.define('textInput', new Transmitter.Nodes.Variable());
    this.define('tagList', new Transmitter.Nodes.List());

    Transmitter.startTransmission( (tr) => {
      new Transmitter.Channels.SimpleChannel()
        .fromSource(this.button)
        .fromSource(this.textInput)
        .inBackwardDirection()
        .withTransform( ([buttonWasClickedPayload, textValuePayload]) =>
          textValuePayload.replaceByNoop(buttonWasClickedPayload)
            .toAppendListElement()
        )
        .toTarget(this.tagList)
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .fromSource(this.button)
        .inForwardDirection()
        .withTransform( (buttonWasClickedPayload) =>
          buttonWasClickedPayload.map( () => '' )
        )
        .toTarget(this.textInput)
        .init(tr);

      this.tagList.init(tr, ['value 1']);
      this.textInput.init(tr, 'value 2');
    });
  });


  specify('when button is clicked', function() {
    Transmitter.startTransmission( (tr) =>
      this.button.originate(tr, 'click')
    );
  });


  specify('text input value should be added to list', function() {
    expect(this.tagList.get()).to.deep.equal(['value 1', 'value 2']);
  });


  specify('text input value should cleared', function() {
    expect(this.textInput.get()).to.equal('');
  });
});
