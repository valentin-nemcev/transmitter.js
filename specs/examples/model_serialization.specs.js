import * as Transmitter from 'transmitter';

describe('Model with view', function() {

  class Model {
    constructor(tr, value) {
      this.valueNode = new Transmitter.Nodes.ValueNode();
      this.valueNode.set(value).init(tr);
    }
  }

  beforeEach(function() {
    this.define('modelMap', new Transmitter.Nodes.OrderedMapNode());
    this.define('serializedValueMap', new Transmitter.Nodes.OrderedMapNode());
    this.define('serializedMap', new Transmitter.Nodes.OrderedMapNode());

    Transmitter.startTransmission(
      (tr) => {
        this.modelMap.set([
          ['id1', new Model(tr, 'value1')],
          ['id2', new Model(tr, 'value2')],
        ]);

        new Transmitter.Channels.SimpleChannel()
          .inBackwardDirection()
          .fromSource(this.serializedValueMap)
          .toTarget(this.modelMap)
          .withTransform(
            (payload, tr) =>
              payload.toMapUpdate( () => new Model(tr) )
          )
          .init(tr);

        new Transmitter.Channels.SimpleChannel()
          .inForwardDirection()
          .fromSource(this.modelMap)
          .toTarget(this.serializedValueMap)
          .withTransform(
            (payload) =>
              payload.toMapUpdate( () => new Transmitter.Nodes.ValueNode() )
          )
          .init(tr);

        new Transmitter.Channels.FlatteningChannel()
          .inBothDirections()
          .withNestedAsOrigin(this.serializedValueMap)
          .withFlat(this.serializedMap)
          .init(tr);
      }
    );
  });


  specify('serializing', function() {

    console.log(this.serializedValueMap.get());
    console.log(this.serializedMap.get());

  });
});

