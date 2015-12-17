import OrderedMapNode from 'transmitter/nodes/OrderedMapNode';
import mapSpecs from './map.specs.js';

describe('Ordered map', function() {

  beforeEach(function() {
    this.map = new OrderedMapNode();
  });

  mapSpecs();

  specify('setting entries', function() {
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

  specify('ordering entries', function() {
    this.map.set([
      ['key1', 'value1'],
      ['key2', 'value2'],
      ['key3', 'value3'],
      ['key4', 'value4'],
    ]);


    this.map.moveAfter('key1', 'key4');
    this.map.moveAfter('key4', null);
    this.map.moveAfter('key2', 'key3');
    this.map.moveAfter('key3', 'key3');

    expect(this.map.get()).to.deep.equal([
      ['key4', 'value4'],
      ['key3', 'value3'],
      ['key2', 'value2'],
      ['key1', 'value1'],
    ]);
  });
});
