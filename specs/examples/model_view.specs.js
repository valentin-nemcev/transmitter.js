import * as Transmitter from 'transmitter';

describe('Model with view', function() {

  let modelId = 0;

  class Model {
    constructor(tr, value) {
      this.id = modelId++;

      this.valueNode = new Transmitter.Nodes.ValueNode();
      this.valueNode.set(value).init(tr);
    }
  }

  class View {
    constructor() {
      this.element = new ViewElement();
      this.valueProp =
        new Transmitter.Nodes.PropertyValueNode(this.element, 'value');
    }
  }

  class ViewElement { }


  beforeEach(function() {
    this.define('modelSet', new Transmitter.Nodes.OrderedSetNode());
    this.define('viewMap', new Transmitter.Nodes.OrderedMapNode());
    this.define('elementSet', new Transmitter.Nodes.OrderedSetNode());
    this.define('channelMap', new Transmitter.ChannelNodes.ChannelMap());

    Transmitter.startTransmission(
      (tr) => {
        this.modelSet.set([new Model(tr, 'value1'), new Model(tr, 'value2')]);

        new Transmitter.Channels.SimpleChannel()
          .inForwardDirection()
          .fromSource(this.modelSet)
          .toTarget(this.viewMap)
          .withTransform(
            (payload) =>
              payload.toMapUpdate( () => new View() )
          )
          .init(tr);

        new Transmitter.Channels.NestedSimpleChannel()
          .fromSourcesWithMatchingPriorities(this.modelSet, this.viewMap)
          .toChannelTarget(this.channelMap)
          .withTransform(
            (payloads) => {
              if (payloads.length == null) return payloads;
              const [models, views] = payloads;
              return models.zip(views).toMapUpdate(
                ([model, view]) =>
                  new Transmitter.Channels.SimpleChannel()
                    .inForwardDirection()
                    .fromSource(model.valueNode)
                    .toTarget(view.valueProp)
              );

            }
          )
          .init(tr);

        new Transmitter.Channels.SimpleChannel()
          .inForwardDirection()
          .fromSource(this.viewMap)
          .toTarget(this.elementSet)
          .withTransform(
            (payload) =>
              payload.map( (view) => view.element )
          )
          .init(tr);
      }
    );
  });


  specify('Maps models to view elements', function() {
    expect(this.elementSet.getSize()).to.equal(2);

    const [element1, element2] = this.elementSet.get();
    expect(element1).to.be.instanceOf(ViewElement);
    expect(element2).to.be.instanceOf(ViewElement);
  });


  specify('Updates nested nodes', function() {
    const [element1, element2] = this.elementSet.get();
    expect(element1).to.deep.equal({value: 'value1'});
    expect(element2).to.deep.equal({value: 'value2'});
  });


  specify('Updates views by key', function() {
    const [, model2] = this.modelSet.get();
    const [, element2] = this.elementSet.get();

    Transmitter.startTransmission(
      (tr) => {
        const model3 = new Model(tr, 'value3');
        this.modelSet.set([model2, model3]).originate(tr);
      }
    );

    expect(this.elementSet.getSize()).to.equal(2);
    expect(this.elementSet.get()[0]).to.equal(element2);
    expect(this.elementSet.get()[1]).to.be.instanceOf(ViewElement);
  });
});
