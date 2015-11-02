import SourceNode from 'transmitter/nodes/source_node';
import SimpleChannel from 'transmitter/channels/simple_channel';
import Transmission from 'transmitter/transmission/transmission';
import Pass from 'transmitter/transmission/pass';

class StubPayload {
  inspect() { return 'stub()'; }
}

class SourceStub extends SourceNode {
  createResponsePayload() { return new StubPayload(); }
}

class TargetStub {
  receiveMessage() {}
}


describe('Message merging', function() {

  before(function() {
    this.target = new TargetStub();
    sinon.spy(this.target, 'receiveMessage');

    this.transmission = new Transmission();
    this.pass = Pass.createMessageDefault();

    this.activePayload = new StubPayload();
    this.passivePayload = new StubPayload();
    this.activeSource = new SourceStub();
    this.passiveSource = new SourceStub();
    sinon.stub(this.activeSource, 'createResponsePayload')
      .returns(this.activePayload);
    sinon.stub(this.passiveSource, 'createResponsePayload')
      .returns(this.passivePayload);

    this.merger = new SimpleChannel()
      .inDirection(this.pass.direction)
      ._createMerger([this.activeSource, this.passiveSource]);

    this.merger.setTarget(this.target);
    const message = this.transmission.createInitialConnectionMessage();
    this.merger.connect(message);
    message.sendToTargetPoints();
  });


  specify('when one active source have sent message', function() {
    this.transmission.originateMessage(this.activeSource, new StubPayload());
  });


  specify('then nothing is sent', function() {
    expect(this.target.receiveMessage).to.not.have.been.called();
  });


  specify('when queries got responses', function() {
    this.transmission.respond();
  });


  specify('and merged message has source payloads', function() {
    const mergedMessage = this.target.receiveMessage.firstCall.args[0];
    const mergedPayload = mergedMessage.getPayload();

    expect(mergedPayload[0]).to.equal(this.activePayload);
    expect(mergedPayload[1]).to.equal(this.passivePayload);
  });
});
