import Transmitter from 'transmitter';

class NestedObject {
  constructor(name) {
    this.name = name;
    this.valueVar = new Transmitter.Nodes.Variable();
  }
}


describe('Flattening list connection', function() {

  beforeEach(function() {
    this.define('serializedVar', new Transmitter.Nodes.Variable());
    this.define('flatList', new Transmitter.Nodes.List());
    this.define('nestedList', new Transmitter.Nodes.List());
    this.define(
      'nestedBackwardChannelVar',
      new Transmitter.ChannelNodes.DynamicChannelVariable(
        'targets', (targets) =>
          new Transmitter.Channels.SimpleChannel()
            .inBackwardDirection()
            .fromSource(this.serializedVar)
            .toDynamicTargets(targets)
            .withTransform( (serializedPayload, nestedPayload) =>
              nestedPayload
                .zipCoercingSize(serializedPayload.toSetList())
                .map( ([ , serialized]) => (serialized || {}).value )
                .unflatten()
            )
      )
    );
    this.define(
      'nestedForwardChannelVar',
      new Transmitter.ChannelNodes.DynamicChannelVariable(
        'sources', (sources) =>
          new Transmitter.Channels.SimpleChannel()
            .inForwardDirection()
            .fromDynamicSources(sources)
            .toTarget(this.flatList)
            .withTransform( (payload) => payload.flatten() )
        )
    );

    Transmitter.startTransmission( (tr) => {
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
        .toTarget(this.nestedList)
        .withTransform( (payload) =>
          payload.toSetList().map( (serialized) =>
            new NestedObject(serialized.name)
          )
        )
        .init(tr);

      new Transmitter.Channels.NestedSimpleChannel()
        .fromSource(this.nestedList)
        .toChannelTarget(this.nestedBackwardChannelVar)
        .withTransform( (nestedList) =>
          nestedList.map( (nested) => nested.valueVar )
        )
        .init(tr);

      new Transmitter.Channels.NestedSimpleChannel()
        .fromSource(this.nestedList)
        .toChannelTarget(this.nestedForwardChannelVar)
        .withTransform( (nestedList) =>
          nestedList.map( (nested) => nested.valueVar )
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
        this.serializedVar.init(tr, serialized)
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
      nestedObjectA.valueVar.init(tr, 'value1');
      nestedObjectB.valueVar.init(tr, 'value2');
      this.nestedList.init(tr, [nestedObjectA, nestedObjectB]);
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
