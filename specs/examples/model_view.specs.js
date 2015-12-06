import * as Transmitter from 'transmitter';

describe('Model with view', function() {

  class Model {
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
              payload.map( (model) => [model, new View()] ).toMap()
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
});
