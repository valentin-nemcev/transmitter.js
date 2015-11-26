import * as Transmitter from 'transmitter';

class NestedObject {
  constructor(name) {
    this.name = name;
    this.valueNode = new Transmitter.Nodes.Value();
  }
}


describe('Flattening connection', function() {
  beforeEach(function() {
    this.define('serializedValue', new Transmitter.Nodes.Value());
    this.define('nestedValue', new Transmitter.Nodes.Optional());

    this.define('flatValue', new Transmitter.Nodes.Optional());

    Transmitter.startTransmission( (tr) => {
      new Transmitter.Channels.FlatteningChannel()
        .inBothDirections()
        .withNestedAsOrigin(this.nestedValue, (nested) => nested.valueNode )
        .withFlat(this.flatValue)
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inForwardDirection()
        .fromSources(this.flatValue, this.nestedValue)
        .toTarget(this.serializedValue)
        .withTransform( ([flatPayload, nestedPayload]) =>
          nestedPayload.zipCoercingSize(flatPayload)
            .map( ([nestedObject, value]) => {
              const name = nestedObject.name;
              return {name, value};
            })
        )
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.serializedValue)
        .toTargets(this.flatValue, this.nestedValue)
        .withTransform( (serializedPayload) =>
          serializedPayload
            .map( (value) => value != null ? value : [] )
            .toList()
            .map( ({value, name}) => [value, new NestedObject(name)] )
            .unzip(2)
        )
        .init(tr);
    });
  });


  describe('queries and updates', function() {

    specify('has default const value after initialization', function() {
      expect(this.serializedValue.get())
      .to.deep.equal(null);
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
        this.serializedValue.query(tr)
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
