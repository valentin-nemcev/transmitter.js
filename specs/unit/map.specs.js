export default function() {
  specify('empty map', function() {
    expect(this.map.get()).to.deep.equal([]);
  });


  specify('getting and setting at key', function() {
    this.map.setAt('key1', 'value1');
    this.map.setAt('key2', 'value2');

    expect(this.map.getAt('key1')).to.equal('value1');
    expect(this.map.getAt('key2')).to.equal('value2');
  });


  specify('getting unset keys', function() {
    expect(this.map.getAt('key')).to.be.undefined();
  });


  specify('overwriting keys', function() {
    this.map.setAt('key', 'valueA');
    this.map.setAt('key', 'valueB');

    expect(this.map.getAt('key')).to.equal('valueB');
    expect(this.map.get()).to.deep.equal([['key', 'valueB']]);
  });


  specify('removing existing keys', function() {
    this.map.setAt('key1', 'value1');
    this.map.setAt('key2', 'value2');

    this.map.removeAt('key1');

    expect(this.map.getAt('key1')).to.be.undefined();
    expect(this.map.getAt('key2')).to.equal('value2');
  });


  specify('removing unset keys', function() {
    this.map.setAt('key1', 'value1');
    this.map.setAt('key2', 'value2');

    this.map.removeAt('unset_key');

    expect(this.map.getAt('key1')).to.equal('value1');
    expect(this.map.getAt('key2')).to.equal('value2');
  });
}
