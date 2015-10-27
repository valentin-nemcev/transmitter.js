import Transmission from 'transmitter/transmission/transmission';
import Pass from 'transmitter/transmission/pass';

class QueryStub {
  constructor(pass) {
    this.pass = pass;
  }

  respond() {
    this._didRespond = true;
    return this;
  }

  readyToRespond() {
    return !this._didRespond;
  }
}

class PointStub {}


describe('Query queue', function() {

  beforeEach(function() {
    this.transmission = new Transmission();
  });

  it('responds to queries from nodes', function() {
    this.query = new QueryStub(Pass.getBackward());
    sinon.spy(this.query, 'respond');

    this.transmission
      .addCommunicationForAndEnqueue(this.query, new PointStub());
    this.transmission.respond();

    expect(this.query.respond).to.have.been.calledOnce();
  });


  it('responds to queries with lower pass priority first', function() {
    this.query1 = new QueryStub(Pass.getBackward());
    this.query2 = new QueryStub(Pass.getForward());
    const callOrder = [];
    sinon.stub(this.query1, 'respond', function() {
      callOrder.push(1);
      this._didRespond = true;
    });
    sinon.stub(this.query2, 'respond', function() {
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
    this.query1 = new QueryStub(Pass.getBackward());
    this.query2 = new QueryStub(Pass.getBackward());
    const callOrder = [];
    sinon.stub(this.query1, 'respond', function() {
      callOrder.push(1);
      this._didRespond = true;
    });
    sinon.stub(this.query2, 'respond', function() {
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
    this.query1 = new QueryStub(Pass.getBackward());
    this.query2 = new QueryStub(Pass.getBackward());
    const callOrder = [];
    sinon.stub(this.query1, 'respond', function() {
      callOrder.push(1);
      this._didRespond = true;
    });
    sinon.stub(this.query2, 'respond', function() {
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
    this.query1 = new QueryStub(Pass.getBackward());
    this.query2 = new QueryStub(Pass.getBackward());
    sinon.stub(this.query1, 'respond', () => {
      this.transmission
        .addCommunicationForAndEnqueue(this.query2, new PointStub());
      this.query1._didRespond = true;
    });
    sinon.spy(this.query2, 'respond');

    this.transmission
      .addCommunicationForAndEnqueue(this.query1, new PointStub());
    this.transmission.respond();

    expect(this.query2.respond).to.have.been.calledOnce();
  });
});
