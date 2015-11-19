import SortedMap from 'transmitter/nodes/SortedMap';

describe('Sorted map', function() {

  let map;

  beforeEach(function() {
    map = new SortedMap();
  });

  specify('empty map', function() {
    expect(map.get()).to.deep.equal([]);
  });


  specify('getting and setting at key', function() {
    map.setAt('key1', 'value1');
    map.setAt('key2', 'value2');

    expect(map.getAt('key1')).to.equal('value1');
    expect(map.getAt('key2')).to.equal('value2');
  });


  specify('getting unset keys', function() {
    expect(map.getAt('key')).to.be.undefined();
  });


  specify('overwriting keys', function() {
    map.setAt('key', 'valueA');
    map.setAt('key', 'valueB');

    expect(map.getAt('key')).to.equal('valueB');
    expect(map.get()).to.deep.equal([['key', 'valueB']]);
  });


  specify('removing existing keys', function() {
    map.setAt('key1', 'value1');
    map.setAt('key2', 'value2');

    map.removeAt('key1');

    expect(map.getAt('key1')).to.be.undefined();
    expect(map.getAt('key2')).to.equal('value2');
  });


  specify('removing unset keys', function() {
    map.setAt('key1', 'value1');
    map.setAt('key2', 'value2');

    map.removeAt('unset_key');

    expect(map.getAt('key1')).to.equal('value1');
    expect(map.getAt('key2')).to.equal('value2');
  });


  specify('setting entries and ordering', function() {
    map.set([
      ['key1', 'value1a'],
      ['key1', 'value1b'],
      ['key4', 'value4'],
      ['key3', 'value3'],
      ['key2', 'value2'],
    ]);

    expect(map.get()).to.deep.equal([
      ['key1', 'value1b'],
      ['key2', 'value2'],
      ['key3', 'value3'],
      ['key4', 'value4'],
    ]);
  });


});
