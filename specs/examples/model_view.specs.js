import * as Transmitter from 'transmitter';

describe('Model with view', function() {

  class Model {
  }

  class View {
  }

  beforeEach(function() {
    this.define('modelSet', new Transmitter.Nodes.OrderedSet());
    this.define('viewSet', new Transmitter.Nodes.OrderedMap());
  });

  specify('empty', function() {
    expect();
  });
});
