import Transmitter from 'transmitter';

class NestedObject {
  constructor(name) {
    this.name = name;
    this.valueVar = new Transmitter.Nodes.Variable();
  }
}


class FlatteningListChannel extends Transmitter.Channels.CompositeChannel {

  inBothDirections() {
    this.channelNodes = [
      new Transmitter.ChannelNodes.DynamicChannelVariable(
        'targets', (targets) =>
          new Transmitter.Channels.SimpleChannel()
            .inBackwardDirection()
            .fromSource(this.flatList)
            .toDynamicTargets(targets)
            .withTransform( (flatPayload, nestedPayload) =>
              flatPayload.fromOptionalToList()
                .coerceSize(nestedPayload).unflatten()
            )
      ),
      new Transmitter.ChannelNodes.DynamicChannelVariable(
        'sources', (sources) =>
          new Transmitter.Channels.SimpleChannel()
            .inForwardDirection()
            .fromDynamicSources(sources)
            .toTarget(this.flatList)
            .withTransform(
              (payload) => payload.flatten().fromListToOptional()
            )
        ),
    ];
    return this;
  }

  withNested(nestedList, mapNested) {
    this.nestedChannel = new Transmitter.Channels.NestedSimpleChannel()
      .fromSource(nestedList)
      .toChannelTargets(...this.channelNodes)
      .withTransform(
        (payload) => payload.map(mapNested).fromOptionalToList()
      );
    return this;
  }

  withFlat(flatList) {
    this.flatList = flatList;
    return this;
  }

  getChannels() {
    return [this.nestedChannel];
  }
}


describe('Flattening connection', function() {
  beforeEach(function() {
    this.define('serializedVar', new Transmitter.Nodes.Variable());
    this.define('nestedVar', new Transmitter.Nodes.Variable());

    this.define('flatVar', new Transmitter.Nodes.Variable());

    Transmitter.startTransmission( (tr) => {
      new FlatteningListChannel()
        .inBothDirections()
        .withNested(this.nestedVar, (nested) => (nested || {}).valueVar )
        .withFlat(this.flatVar)
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
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
        )
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.serializedVar)
        .toTargets(this.flatVar, this.nestedVar)
        .withTransform( (serializedPayload) =>
          serializedPayload
            .map( ({value, name}) => [value, new NestedObject(name)] )
            .separate()
        )
        .init(tr);
    });
  });


  describe('queries and updates', function() {

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

    function id(arg) { return arg; }

    beforeEach(function() {
      this.define('serializedDerivedVar', new Transmitter.Nodes.Variable());
      Transmitter.startTransmission( (tr) =>
        new Transmitter.Channels.BidirectionalChannel()
          .inBothDirections()
          .withOriginDerived(this.serializedVar, this.serializedDerivedVar)
          .withMapOrigin(id)
          .withMapDerived(id)
          .init(tr)
      );
    });


    ['straight', 'reverse'].forEach(function(order) {
      specify('querying source and target ' +
              'results in correct response order (' + order + ')', function() {
        Transmitter.startTransmission( (tr) => {
          tr.reverseOrder = order === 'reverse';

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
