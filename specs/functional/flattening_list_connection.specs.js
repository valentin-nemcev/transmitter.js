import * as Transmitter from 'transmitter';

class NestedObject {
  constructor(name) {
    this.name = name;
    this.valueNode = new Transmitter.Nodes.ValueNode();
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
    this.define('serializedValue', new Transmitter.Nodes.ValueNode());
    this.define('nestedList', new Transmitter.Nodes.ListNode());

    this.define('flatList', new Transmitter.Nodes.ListNode());

    Transmitter.startTransmission( (tr) => {
      new Transmitter.Channels.FlatteningChannel()
        .inBothDirections()
        .withNestedAsOrigin(this.nestedList, (nested) => nested.valueNode )
        .withFlat(this.flatList)
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inForwardDirection()
        .fromSources(this.flatList, this.nestedList)
        .toTarget(this.serializedValue)
        .withTransform( ([flatPayload, nestedPayload]) =>
          nestedPayload.zipCoercingSize(flatPayload)
            .map( ([nestedObject, value]) => {
              const name = nestedObject.name;
              return {name, value};
            })
            .joinValues()
        )
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.serializedValue)
        .toTargets(this.flatList, this.nestedList)
        .withTransform( (serializedPayload) =>
          serializedPayload
            .splitValues()
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

    Transmitter.startTransmission(
      (tr) => this.serializedValue.set(serialized).init(tr)
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
