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
              flatPayload.coerceSize(nestedPayload).unflatten()
            )
      ),
      new Transmitter.ChannelNodes.DynamicChannelVariable(
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
   *         nestedList          serializedVar
   *           .  |<------------------|
   *           .  |                /  |
   *           .  |---------------/-->|
   *           .  |           /  /
   *      ......  | flatList /  /
   *      .       |..     |--  /
   * valueVars      .     |   /
   *     |----------*---->|<--
   *     |          .     |
   *     |<---------*-----|
   */

  beforeEach(function() {
    this.define('serializedVar', new Transmitter.Nodes.Variable());
    this.define('nestedList', new Transmitter.Nodes.List());

    this.define('flatList', new Transmitter.Nodes.List());

    Transmitter.startTransmission( (tr) => {
      new FlatteningListChannel()
        .inBothDirections()
        .withNested(this.nestedList, (nested) => nested.valueVar )
        .withFlat(this.flatList)
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inForwardDirection()
        .fromSources(this.flatList, this.nestedList)
        .toTarget(this.serializedVar)
        .withTransform( ([flatPayload, nestedPayload]) =>
          flatPayload.zip(nestedPayload)
            .map( ([value, nestedObject]) => {
              const name = (nestedObject || {}).name;
              return {
                name: name != null ? name : null,
                value: value != null ? value : null,
              };
            })
            .toSetVariable()
        )
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.serializedVar)
        .toTargets(this.flatList, this.nestedList)
        .withTransform( (serializedPayload) =>
          serializedPayload.toSetList()
            .map( ({value, name}) => [value, new NestedObject(name)] )
            .unzip(2)
        )
        .init(tr);
    });
  });


  specify('has default const value after initialization', function() {
    expect(this.serializedVar.get()).to.deep.equal([]);
  });


  specify('creation of nested target after flat source update', function() {
    const serialized = [
      {name: 'objectA', value: 'value1'},
      {name: 'objectB', value: 'value2'},
    ];

    Transmitter.startTransmission( (tr) =>
        this.serializedVar.set(serialized).init(tr)
    );

    const nestedObjects = this.nestedList.get();
    expect(nestedObjects.length).to.equal(2);
    expect(nestedObjects[0].name).to.equal('objectA');
    expect(nestedObjects[0].valueVar.get()).to.equal('value1');
    expect(nestedObjects[1].name).to.equal('objectB');
    expect(nestedObjects[1].valueVar.get()).to.equal('value2');
  });


  specify('updating flat target after outer and inner source update',
  function() {
    const nestedObjectA = new NestedObject('objectA');
    const nestedObjectB = new NestedObject('objectB');

    Transmitter.startTransmission( (tr) => {
      nestedObjectA.valueVar.set('value1').init(tr);
      nestedObjectB.valueVar.set('value2').init(tr);
      this.nestedList.set([nestedObjectA, nestedObjectB]).init(tr);
    });

    expect(this.serializedVar.get()).to.deep.equal([
      {name: 'objectA', value: 'value1'},
      {name: 'objectB', value: 'value2'},
    ]);
  });


  specify('querying flat target after outer source update', function() {
    const nestedObjectA = new NestedObject('objectA');
    const nestedObjectB = new NestedObject('objectB');
    nestedObjectA.valueVar.set('value1');
    nestedObjectB.valueVar.set('value2');
    this.nestedList.set([nestedObjectA, nestedObjectB]);

    Transmitter.startTransmission( (tr) =>
        this.serializedVar.queryState(tr)
    );

    expect(this.serializedVar.get()).to.deep.equal([
      {name: 'objectA', value: 'value1'},
      {name: 'objectB', value: 'value2'},
    ]);
  });
});
