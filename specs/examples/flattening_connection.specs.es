import Transmitter from 'transmitter';

class NestedObject {
  constructor(name) {
    this.name = name;
    this.valueVar = new Transmitter.Nodes.Variable();
  }
}

describe('Flattening connection', function() {
  beforeEach(function() {
    this.define('serializedVar', new Transmitter.Nodes.Variable());
    this.define('flatVar', new Transmitter.Nodes.Variable());
    this.define('nestedVar', new Transmitter.Nodes.Variable());
    this.define(
      'nestedBackwardChannelVar',
      new Transmitter.ChannelNodes.DynamicChannelVariable('targets', () =>
        new Transmitter.Channels.SimpleChannel()
          .inBackwardDirection()
          .fromSource(this.serializedVar)
          .withTransform( (serializedPayload) =>
            serializedPayload
              .map( (serialized) => [(serialized || {}).value] )
              .toSetList()
              .unflatten()
          )
      )
    );
    this.define(
      'nestedForwardChannelVar',
      new Transmitter.ChannelNodes.DynamicChannelVariable('sources', () =>
        new Transmitter.Channels.SimpleChannel()
          .inForwardDirection()
          .toTarget(this.flatVar)
          .withTransform( (valuePayloads) =>
            valuePayloads.flatten().toSetVariable().map( ([value]) => value )
          )
      )
    );

    this.createFlatChannel = function() {
      const ch = new Transmitter.Channels.CompositeChannel();
      ch.defineSimpleChannel()
        .inForwardDirection()
        .fromSources(this.flatVar, this.nestedVar)
        .toTarget(this.serializedVar)
        .withTransform( ([flatPayload, nestedPayload]) =>
          flatPayload.merge(nestedPayload).map( ([value, nestedObject]) => {
            const name = (nestedObject || {}).name;
            return {
              name: name != null ? name : null,
              value: value != null ? value : null,
            };
          })
        );

      ch.defineSimpleChannel()
        .inBackwardDirection()
        .fromSource(this.serializedVar)
        .toTarget(this.nestedVar)
        .withTransform( (payload) =>
          payload.map( (serialized) =>
            serialized != null ? new NestedObject(serialized.name) : null
          )
        );

      return ch;
    };

    this.createNestedChannel = function() {
      return new Transmitter.Channels.SimpleChannel()
      .fromSource(this.nestedVar)
      .toConnectionTargets(
        this.nestedBackwardChannelVar,
        this.nestedForwardChannelVar)
      .withTransform( (payload) =>
        payload.map( (nestedObject) =>
          nestedObject != null ? [nestedObject.valueVar] : []
        )
      );
    };
  });


  describe('initialization', function() {

    specify('has default const value after initialization', function() {
      Transmitter
        .startTransmission( (tr) => this.createFlatChannel().init(tr) );

      // Separate transmissions to test channel init querying
      Transmitter
        .startTransmission( (tr) => this.createNestedChannel().init(tr) );

      expect(this.serializedVar.get())
        .to.deep.equal({name: null, value: null});
    });
  });


  describe('queries and updates', function() {

    beforeEach(function() {
      Transmitter.startTransmission( (tr) => {
        this.createFlatChannel().init(tr);
        this.createNestedChannel().init(tr);
      });
    });


    specify('has default const value after initialization', function() {
      expect(this.serializedVar.get())
      .to.deep.equal({name: null, value: null});
    });


    specify('creation of nested target after flat source update', function() {
      const serialized = {name: 'objectA', value: 'value1'};

      Transmitter
        .startTransmission( (tr) => this.serializedVar.init(tr, serialized) );

      const nestedObject = this.nestedVar.get();
      expect(nestedObject.name).to.equal('objectA');
      expect(nestedObject.valueVar.get()).to.equal('value1');
    });


    specify('updating flat target after outer and inner source update',
    function() {
      const nestedObject = new NestedObject('objectA');

      Transmitter.startTransmission( (tr) => {
        nestedObject.valueVar.init(tr, 'value1');
        this.nestedVar.init(tr, nestedObject);
      });

      expect(this.serializedVar.get())
      .to.deep.equal({name: 'objectA', value: 'value1'});
    });


    specify('updating flat target after outer only source update', function() {
      const nestedObject = new NestedObject('objectA');
      nestedObject.valueVar.set('value0');
      this.serializedVar.set({name: 'objectA', value: 'value1'});

      Transmitter.startTransmission( (tr) =>
          this.nestedVar.init(tr, nestedObject)
      );

      expect(nestedObject.valueVar.get()).to.deep.equal('value1');
    });


    specify('querying flat target after outer source update', function() {
      const nestedObject = new NestedObject('objectA');
      nestedObject.valueVar.set('value1');
      this.nestedVar.set(nestedObject);

      Transmitter.startTransmission( (tr) =>
        this.serializedVar.queryState(tr)
      );

      expect(this.serializedVar.get())
        .to.deep.equal({name: 'objectA', value: 'value1'});
    });
  });


  describe('nesting order', function() {

    beforeEach(function() {
      this.define('serializedDerivedVar', new Transmitter.Nodes.Variable());
      this.createDerivedChannel = function() {
        return new Transmitter.Channels.VariableChannel()
          .withOrigin(this.serializedVar)
          .withDerived(this.serializedDerivedVar);
      };
    });


    ['straight', 'reverse'].forEach(function(order) {
      specify('querying source and target ' +
              'results in correct response order (' + order + ')', function() {
        Transmitter.startTransmission( (tr) => {
          tr.reverseOrder = order === 'reverse';
          this.createFlatChannel().init(tr);
          this.createNestedChannel().init(tr);
          this.createDerivedChannel().init(tr);

          const nestedObject = new NestedObject('objectA');
          nestedObject.valueVar.init(tr, 'value1');
          this.nestedVar.init(tr, nestedObject);
        });

        expect(this.serializedDerivedVar.get())
        .to.deep.equal({name: 'objectA', value: 'value1'});
      });
    });
  });
});
