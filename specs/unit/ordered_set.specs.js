import OrderedSetNode from 'transmitter/nodes/OrderedSetNode';

describe('Ordered set', function() {

  beforeEach(function() {
    this.set = new OrderedSetNode();
  });

  specify('adding and checking value', function() {
    this.set.add('value1');
    this.set.add('value2');

    expect(this.set.has('value1')).to.be.true();
    expect(this.set.has('value2')).to.be.true();
  });


  specify('getting not added values', function() {
    expect(this.set.has('value')).to.be.false();
  });


  specify('removing existing values', function() {
    this.set.add('value1');
    this.set.add('value2');

    this.set.remove('value1');

    expect(this.set.has('value1')).to.be.false();
    expect(this.set.has('value2')).to.be.true();
  });


  specify('removing unset keys', function() {
    this.set.add('value1');
    this.set.add('value2');

    this.set.remove('value3');

    expect(this.set.has('value1')).to.be.true();
    expect(this.set.has('value2')).to.be.true();
  });


  specify('setting entries and ordering', function() {
    this.set.set([
      'value1',
      'value1',
      'value4',
      'value3',
      'value2',
    ]);

    expect(this.set.get()).to.deep.equal([
      'value1',
      'value4',
      'value3',
      'value2',
    ]);
  });
});
