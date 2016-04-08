import Transmission from 'transmitter/transmission/Transmission';
import Passes from 'transmitter/transmission/Passes';

class QueryStub {
  constructor(pass) {
    this.pass = pass;
  }

  sendMessage() {
    this._didRespond = true;
    return this;
  }

  messageReady() {
    return !this._didRespond;
  }
}

class PointStub {}


describe('Query queue', function() {

  beforeEach(function() {
    this.transmission = new Transmission();
  });

  it('responds to queries from nodes', function() {
    this.query = new QueryStub(Passes.getBackward());
    sinon.spy(this.query, 'sendMessage');

    this.transmission
      .addCommunicationForAndEnqueue(this.query, new PointStub());
    this.transmission.respond();

    expect(this.query.sendMessage).to.have.been.calledOnce();
  });


  it('responds to queries with lower pass priority first', function() {
    this.query1 = new QueryStub(Passes.getBackward());
    this.query2 = new QueryStub(Passes.getForward());
    const callOrder = [];
    sinon.stub(this.query1, 'sendMessage', function() {
      callOrder.push(1);
      this._didRespond = true;
    });
    sinon.stub(this.query2, 'sendMessage', function() {
      callOrder.push(2);
      this._didRespond = true;
    });

    this.transmission
      .addCommunicationForAndEnqueue(this.query2, new PointStub());
    this.transmission
      .addCommunicationForAndEnqueue(this.query1, new PointStub());
    this.transmission.respond();

    expect(callOrder).to.deep.equal([1, 2]);
  });


  it('behaves like FIFO for queries with the same order', function() {
    this.query1 = new QueryStub(Passes.getBackward());
    this.query2 = new QueryStub(Passes.getBackward());
    const callOrder = [];
    sinon.stub(this.query1, 'sendMessage', function() {
      callOrder.push(1);
      this._didRespond = true;
    });
    sinon.stub(this.query2, 'sendMessage', function() {
      callOrder.push(2);
      this._didRespond = true;
    });

    this.transmission
      .addCommunicationForAndEnqueue(this.query1, new PointStub());
    this.transmission
      .addCommunicationForAndEnqueue(this.query2, new PointStub());
    this.transmission.respond();

    expect(callOrder).to.deep.equal([1, 2]);
  });


  it('has option to reverse queries with the same order for testing',
  function() {
    this.query1 = new QueryStub(Passes.getBackward());
    this.query2 = new QueryStub(Passes.getBackward());
    const callOrder = [];
    sinon.stub(this.query1, 'sendMessage', function() {
      callOrder.push(1);
      this._didRespond = true;
    });
    sinon.stub(this.query2, 'sendMessage', function() {
      callOrder.push(2);
      this._didRespond = true;
    });

    this.transmission.reverseOrder = true;
    this.transmission
      .addCommunicationForAndEnqueue(this.query1, new PointStub());
    this.transmission
      .addCommunicationForAndEnqueue(this.query2, new PointStub());
    this.transmission.respond();

    expect(callOrder).to.deep.equal([2, 1]);
  });


  it('responds to queries created as a result of previous response',
  function() {
    this.query1 = new QueryStub(Passes.getBackward());
    this.query2 = new QueryStub(Passes.getBackward());
    sinon.stub(this.query1, 'sendMessage', () => {
      this.transmission
        .addCommunicationForAndEnqueue(this.query2, new PointStub());
      this.query1._didRespond = true;
    });
    sinon.spy(this.query2, 'sendMessage');

    this.transmission
      .addCommunicationForAndEnqueue(this.query1, new PointStub());
    this.transmission.respond();

    expect(this.query2.sendMessage).to.have.been.calledOnce();
  });
});
