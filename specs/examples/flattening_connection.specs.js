import Transmitter from 'transmitter';

class NestedObject {
  constructor(name) {
    this.name = name;
    this.valueNode = new Transmitter.Nodes.Value();
  }
}


class FlatteningListChannel extends Transmitter.Channels.CompositeChannel {

  inBothDirections() {
    this.channelNodes = [
      new Transmitter.ChannelNodes.DynamicChannelValue(
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
      new Transmitter.ChannelNodes.DynamicChannelValue(
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
    this.addChannel(new Transmitter.Channels.NestedSimpleChannel()
      .fromSource(nestedList)
      .toChannelTargets(...this.channelNodes)
      .withTransform(
        (payload) => payload.map(mapNested).fromOptionalToList()
      ));
    return this;
  }

  withFlat(flatList) {
    this.flatList = flatList;
    return this;
  }
}


describe('Flattening connection', function() {
  beforeEach(function() {
    this.define('serializedValue', new Transmitter.Nodes.Value());
    this.define('nestedValue', new Transmitter.Nodes.Value());

    this.define('flatValue', new Transmitter.Nodes.Value());

    Transmitter.startTransmission( (tr) => {
      new FlatteningListChannel()
        .inBothDirections()
        .withNested(this.nestedValue, (nested) => (nested || {}).valueNode )
        .withFlat(this.flatValue)
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inForwardDirection()
        .fromSources(this.flatValue, this.nestedValue)
        .toTarget(this.serializedValue)
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
        .fromSource(this.serializedValue)
        .toTargets(this.flatValue, this.nestedValue)
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
      expect(this.serializedValue.get())
      .to.deep.equal({name: null, value: null});
    });


    specify('creation of nested target after flat source update', function() {
      const serialized = {name: 'objectA', value: 'value1'};

      Transmitter.startTransmission( (tr) =>
        this.serializedValue.set(serialized).init(tr)
      );

      const nestedObject = this.nestedValue.get();
      expect(nestedObject.name).to.equal('objectA');
      expect(nestedObject.valueNode.get()).to.equal('value1');
    });


    specify('updating flat target after outer and inner source update',
    function() {
      const nestedObject = new NestedObject('objectA');

      Transmitter.startTransmission( (tr) => {
        nestedObject.valueNode.set('value1').init(tr);
        this.nestedValue.set(nestedObject).init(tr);
      });

      expect(this.serializedValue.get())
      .to.deep.equal({name: 'objectA', value: 'value1'});
    });


    specify('updating flat target after outer only source update', function() {
      const nestedObject = new NestedObject('objectA');
      nestedObject.valueNode.set('value0');
      this.serializedValue.set({name: 'objectA', value: 'value1'});

      Transmitter.startTransmission( (tr) =>
          this.nestedValue.set(nestedObject).init(tr)
      );

      expect(nestedObject.valueNode.get()).to.deep.equal('value1');
    });


    specify('querying flat target after outer source update', function() {
      const nestedObject = new NestedObject('objectA');
      nestedObject.valueNode.set('value1');
      this.nestedValue.set(nestedObject);

      Transmitter.startTransmission( (tr) =>
        this.serializedValue.queryState(tr)
      );

      expect(this.serializedValue.get())
        .to.deep.equal({name: 'objectA', value: 'value1'});
    });
  });


  describe('nesting order', function() {

    function id(arg) { return arg; }

    beforeEach(function() {
      this.define('serializedDerivedValue', new Transmitter.Nodes.Value());
      Transmitter.startTransmission( (tr) =>
        new Transmitter.Channels.BidirectionalChannel()
          .inBothDirections()
          .withOriginDerived(this.serializedValue, this.serializedDerivedValue)
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
          nestedObject.valueNode.set('value1').init(tr);
          this.nestedValue.set(nestedObject).init(tr);
        });

        expect(this.serializedDerivedValue.get())
        .to.deep.equal({name: 'objectA', value: 'value1'});
      });
    });
  });
});
