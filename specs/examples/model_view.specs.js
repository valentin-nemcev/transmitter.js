import * as Transmitter from 'transmitter';

describe('Model with view', function() {

  class Model {
  }

  class View {
  }

  beforeEach(function() {
    this.define('modelSet', new Transmitter.Nodes.OrderedSet());
    this.define('viewMap', new Transmitter.Nodes.OrderedMap());
    this.define('elementSet', new Transmitter.Nodes.OrderedSet());

    Transmitter.startTransmission(
      (tr) =>
        this.modelSet.set(new Model(tr), new Model(tr))
    );
  });

  specify('empty', function() {
    expect();
  });
});
