import SourceNode from 'transmitter/nodes/source_node';
import TargetNode from 'transmitter/nodes/target_node';
import SimpleChannel from 'transmitter/channels/simple_channel';
import Transmission from 'transmitter/transmission/transmission';
import Transmitter from 'transmitter';


class StubPayload {
  inspect() { return 'stub()'; }
  deliver() {}
}

class NodeSourceStub extends SourceNode {
  createResponsePayload(payload) { return payload; }
}

class NodeTargetStub extends TargetNode {
  acceptPayload(payload) {
    payload.deliver(this);
    return this;
  }
}


describe('Message and query transmission', function() {

  beforeEach(function() {
    this.source = new NodeSourceStub();
    this.target = new NodeTargetStub();
  });


  it('transmits message from source to target', function() {
    Transmitter.startTransmission( (tr) =>
      new SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.source)
        .toTarget(this.target)
        .withoutTransform()
        .init(tr)
    );

    this.transmission = new Transmission();

    this.payload = new StubPayload();
    sinon.spy(this.payload, 'deliver');
    this.transmission.originateMessage(this.source, this.payload);

    expect(this.payload.deliver)
      .to.have.been.calledWithSame(this.target);
  });


  it('transmits query from source to target', function() {
    this.payload = new StubPayload();
    sinon.spy(this.payload, 'deliver');
    sinon.stub(this.source, 'createResponsePayload').returns(this.payload);

    Transmitter.startTransmission( (tr) =>
      new SimpleChannel()
        .inForwardDirection()
        .fromSource(this.source)
        .toTarget(this.target)
        .withoutTransform()
        .init(tr)
    );

    this.transmission = new Transmission();

    this.transmission.originateQuery(this.target);
    this.transmission.respond();

    expect(this.payload.deliver)
      .to.have.been.calledWithSame(this.target);
  });
});