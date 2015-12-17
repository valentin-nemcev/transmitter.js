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
    this.define('serializedValue', new Transmitter.Nodes.ValueNode());

    Transmitter.startTransmission(
      (tr) => {
        this.modelMap.set([
          ['id1', new Model(tr, 'value1')],
          ['id2', new Model(tr, 'value2')],
          ['id3', new Model(tr, 'value3')],
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

        function createSerializeModelChannel(model, serializedValue) {
          return new Transmitter.Channels.BidirectionalChannel()
            .inBothDirections()
            .withOriginDerived(model.valueNode, serializedValue);
        }

        new Transmitter.Channels.NestedSimpleChannel()
          .fromSourcesWithMatchingPriorities(
            this.modelMap, this.serializedValueMap
          )
          .toChannelTarget(new Transmitter.ChannelNodes.ChannelMap())
          .withTransform(
            (payloads) => {
              if (payloads.length == null) return payloads;
              const [origin, derived] = payloads;
              return origin.zip(derived)
                .toMapUpdate(
                  ([origin, derived]) =>
                    createSerializeModelChannel(origin, derived)
                );
            }
          )
          .init(tr);

        new Transmitter.Channels.FlatteningChannel()
          .inBothDirections()
          .withNestedAsOrigin(this.serializedValueMap)
          .withFlat(this.serializedMap)
          .init(tr);


        new Transmitter.Channels.BidirectionalChannel()
          .inForwardDirection()
          .withOriginDerived(this.serializedMap, this.serializedValue)
          .withTransformOrigin(
            (payload) => payload.joinEntries().map(
              (entries) => {
                const obj = {};
                for (const [key, value] of entries) obj[key] = value;
                return obj;
              }
            )
          )
          .withTransformDerived(
            (payload) => payload.map(
              (obj) => Object.entries(obj)
            ).valuesToEntries()
          )
          .init(tr);
      }
    );
  });


  specify('serializing', function() {
    expect(this.serializedValue.get()).to.deep.equal({
      'id1': 'value1',
      'id2': 'value2',
      'id3': 'value3',
    });
  });


  specify('unserializing', function() {
    Transmitter.startTransmission(
      (tr) =>
        this.serializedValue.set({
          'id3': 'value3a',
          'id2': 'value2',
          'id4': 'value4',
        }).originate(tr)
    );
  });

});
