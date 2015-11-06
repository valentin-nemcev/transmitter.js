import Transmitter from 'transmitter';

const VariableNode = Transmitter.Nodes.Variable;

const merge = Transmitter.Payloads.VariablePayload.merge;

function reduceMergedPayload(...nodes) {
  return function(payloads) {
    return merge(payloads).map( (values) => {
      const result = {};
      values.forEach( (value, i) => result[nodes[i].inspect()] = value );
      return result;
    });
  };
}

describe('Multilevel merging 1', function() {

  //         c1
  //        /
  // a ----b1----d1
  //     \     \
  //      b2    d2

  beforeEach(function() {
    this.define('a', new VariableNode());
    this.define('b1', new VariableNode());
    this.define('b2', new VariableNode());

    this.b2.set('b2Value');

    this.define('c1', new VariableNode());

    // c1 should always have same value as b1, but this particular test
    // assertions should never see it
    this.c1.set('UnusedValue');

    this.define('d1', new VariableNode());
    this.define('d2', new VariableNode());

    this.d1.set('d1Value');
    this.d2.set('d2Value');

    Transmitter.startTransmission( (tr) => {
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSources(this.d1, this.d2)
        .toTarget(this.b1)
        .withTransform(reduceMergedPayload(this.d1, this.d2))
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.c1)
        .toTarget(this.b1)
        .withoutTransform()
        .init(tr);

      return new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSources(this.b1, this.b2)
        .toTarget(this.a)
        .withTransform(reduceMergedPayload(this.b1, this.b2))
        .init(tr);
    });
  });


  ['straight', 'reverse'].forEach( (order) =>
    specify('multiple messages are transmitted and merged '
            + 'in correct order (' + order + ')', function() {
      Transmitter.startTransmission( (tr) => {
        tr.reverseOrder = order === 'reverse';
        this.d2.set('d2UpdatedValue').init(tr);
        this.b2.set('b2UpdatedValue').init(tr);
      });

      expect(this.a.get()).to.deep.equal({
        b1: {
          d1: 'd1Value',
          d2: 'd2UpdatedValue',
        },
        b2: 'b2UpdatedValue',
      });
    })
  );
});


describe('Multilevel merging 2', function() {

  // a ----b1
  //  \  \
  //   ---b2

  beforeEach(function() {
    this.define('a', new VariableNode());
    this.define('b1', new VariableNode());
    this.define('b2', new VariableNode());

    this.b2.set('b2Value');

    this.bind1 = function(tr) {
      return new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSources(this.b1, this.b2)
        .toTarget(this.a)
        .withTransform(reduceMergedPayload(this.b1, this.b2))
        .init(tr);
    };

    this.bind2 = function(tr) {
      return new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.b2)
        .toTarget(this.a)
        .withoutTransform()
        .init(tr);
    };
  });


  ['straight', 'reverse'].forEach( (order) =>
    specify('multiple messages are transmitted and merged '
            + 'in correct order (' + order + ')', function() {
      Transmitter.startTransmission( (tr) => {
        if (order === 'straight') {
          this.bind1(tr);
          this.bind2(tr);
        } else {
          this.bind2(tr);
          this.bind1(tr);
        }
      });

      Transmitter.startTransmission( (tr) => this.b1.set('b1Value').init(tr) );

      expect(this.a.get()).to.deep.equal({
        b1: 'b1Value',
        b2: 'b2Value',
      });
    })
  );
});
