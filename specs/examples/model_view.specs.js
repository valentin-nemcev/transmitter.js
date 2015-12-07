import * as Transmitter from 'transmitter';

describe('Model with view', function() {

  let modelId = 0;

  class Model {
    constructor() {
      this.id = modelId++;
    }
  }

  class View {
    constructor() {
      this.element = new ViewElement();
    }
  }

  class ViewElement {
  }


  beforeEach(function() {
    this.define('modelSet', new Transmitter.Nodes.OrderedSet());
    this.define('viewMap', new Transmitter.Nodes.OrderedMap());
    this.define('elementSet', new Transmitter.Nodes.OrderedSet());

    Transmitter.startTransmission(
      (tr) => {
        this.modelSet.set([new Model(tr), new Model(tr)]);

        new Transmitter.Channels.SimpleChannel()
          .inForwardDirection()
          .fromSource(this.modelSet)
          .toTarget(this.viewMap)
          .withTransform(
            (payload) =>
              payload.toMapUpdate( () => new View() )
          )
          .init(tr);

        new Transmitter.Channels.SimpleChannel()
          .inForwardDirection()
          .fromSource(this.viewMap)
          .toTarget(this.elementSet)
          .withTransform(
            (payload) =>
              payload.toSet().map( (view) => view.element )
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


  specify('Updates views by key', function() {
    const [, model2] = this.modelSet.get();
    const model3 = new Model();
    const [, element2] = this.elementSet.get();

    Transmitter.startTransmission(
      (tr) =>
        this.modelSet.set([model2, model3]).originate(tr)
    );

    expect(this.elementSet.getSize()).to.equal(2);
    expect(this.elementSet.get()[0]).to.equal(element2);
    expect(this.elementSet.get()[1]).to.be.instanceOf(ViewElement);
  });
});
