import OrderedMapNode from 'transmitter/nodes/OrderedMapNode';
import mapSpecs from './map.specs.js';

describe('Ordered map', function() {

  beforeEach(function() {
    this.map = new OrderedMapNode();
  });

  mapSpecs();

  specify('setting entries and ordering', function() {
    this.map.set([
      ['key1', 'value1a'],
      ['key1', 'value1b'],
      ['key4', 'value4'],
      ['key3', 'value3'],
      ['key2', 'value2'],
    ]);

    expect(this.map.get()).to.deep.equal([
      ['key1', 'value1b'],
      ['key4', 'value4'],
      ['key3', 'value3'],
      ['key2', 'value2'],
    ]);
  });
});
