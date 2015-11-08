import * as Transmitter from 'transmitter';

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
              flatPayload.coerceSize(nestedPayload).unflatten()
            )
      ),
      new Transmitter.ChannelNodes.DynamicChannelValue(
        'sources', (sources) =>
          new Transmitter.Channels.SimpleChannel()
            .inForwardDirection()
            .fromDynamicSources(sources)
            .toTarget(this.flatList)
            .withTransform( (payload) => payload.flatten() )
        ),
    ];
    return this;
  }

  withNested(nestedList, mapNested) {
    this.addChannel(new Transmitter.Channels.NestedSimpleChannel()
      .fromSource(nestedList)
      .toChannelTargets(...this.channelNodes)
      .withTransform( (payload) => payload.map(mapNested) ));
    return this;
  }

  withFlat(flatList) {
    this.flatList = flatList;
    return this;
  }
}


describe('Flattening list connection', function() {

  /**
   *
   *         nestedList          serializedValue
   *           .  |<------------------|
   *           .  |                /  |
   *           .  |---------------/-->|
   *           .  |           /  /
   *      ......  | flatList /  /
   *      .       |..     |--  /
   * valueNodes     .     |   /
   *     |----------*---->|<--
   *     |          .     |
   *     |<---------*-----|
   */

  beforeEach(function() {
    this.define('serializedValue', new Transmitter.Nodes.Value());
    this.define('nestedList', new Transmitter.Nodes.List());

    this.define('flatList', new Transmitter.Nodes.List());

    Transmitter.startTransmission( (tr) => {
      new FlatteningListChannel()
        .inBothDirections()
        .withNested(this.nestedList, (nested) => nested.valueNode )
        .withFlat(this.flatList)
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inForwardDirection()
        .fromSources(this.flatList, this.nestedList)
        .toTarget(this.serializedValue)
        .withTransform( ([flatPayload, nestedPayload]) =>
          flatPayload.zip(nestedPayload)
            .map( ([value, nestedObject]) => {
              const name = (nestedObject || {}).name;
              return {
                name: name != null ? name : null,
                value: value != null ? value : null,
              };
            })
            .toValue()
        )
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.serializedValue)
        .toTargets(this.flatList, this.nestedList)
        .withTransform( (serializedPayload) =>
          serializedPayload.toList()
            .map( ({value, name}) => [value, new NestedObject(name)] )
            .unzip(2)
        )
        .init(tr);
    });
  });


  specify('has default const value after initialization', function() {
    expect(this.serializedValue.get()).to.deep.equal([]);
  });


  specify('creation of nested target after flat source update', function() {
    const serialized = [
      {name: 'objectA', value: 'value1'},
      {name: 'objectB', value: 'value2'},
    ];

    Transmitter.startTransmission( (tr) =>
        this.serializedValue.set(serialized).init(tr)
    );

    const nestedObjects = this.nestedList.get();
    expect(nestedObjects.length).to.equal(2);
    expect(nestedObjects[0].name).to.equal('objectA');
    expect(nestedObjects[0].valueNode.get()).to.equal('value1');
    expect(nestedObjects[1].name).to.equal('objectB');
    expect(nestedObjects[1].valueNode.get()).to.equal('value2');
  });


  specify('updating flat target after outer and inner source update',
  function() {
    const nestedObjectA = new NestedObject('objectA');
    const nestedObjectB = new NestedObject('objectB');

    Transmitter.startTransmission( (tr) => {
      nestedObjectA.valueNode.set('value1').init(tr);
      nestedObjectB.valueNode.set('value2').init(tr);
      this.nestedList.set([nestedObjectA, nestedObjectB]).init(tr);
    });

    expect(this.serializedValue.get()).to.deep.equal([
      {name: 'objectA', value: 'value1'},
      {name: 'objectB', value: 'value2'},
    ]);
  });


  specify('querying flat target after outer source update', function() {
    const nestedObjectA = new NestedObject('objectA');
    const nestedObjectB = new NestedObject('objectB');
    nestedObjectA.valueNode.set('value1');
    nestedObjectB.valueNode.set('value2');
    this.nestedList.set([nestedObjectA, nestedObjectB]);

    Transmitter.startTransmission( (tr) =>
        this.serializedValue.query(tr)
    );

    expect(this.serializedValue.get()).to.deep.equal([
      {name: 'objectA', value: 'value1'},
      {name: 'objectB', value: 'value2'},
    ]);
  });
});
