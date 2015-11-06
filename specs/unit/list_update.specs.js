import ListPayload from 'transmitter/payloads/ListPayload';
import List from 'transmitter/nodes/List';


describe('List update', function() {

  function id(a) { return a; }
  function equals(a, b) { return a === b; }

  beforeEach(function() {
    this.target = new List();
    this.updateTarget = (list) =>
        ListPayload.setConst(list)
          .updateMatching(id, equals)
          .deliver(this.target);

    this.added = sinon.spy(this.target, 'addAt');
    this.removed = sinon.spy(this.target, 'removeAt');
    this.moved = sinon.spy(this.target, 'move');
  });


  specify('Set different elements', function() {
    this.target.set(['element1', 'element2', 'element3']);

    this.updateTarget(['new element1', 'new element2']);

    assert.deepEqual(this.target.get(), ['new element1', 'new element2']);

    assert.equal(this.removed.callCount, 3);
    assert.equal(this.added.callCount, 2);
    assert.equal(this.moved.callCount, 0);
  });


  specify('Set same elements', function() {
    this.target.set(['element1', 'element2', 'element3']);

    this.updateTarget(['element1', 'element2', 'element3']);

    assert.deepEqual(this.target.get(), ['element1', 'element2', 'element3']);

    assert.equal(this.added.callCount, 0);
    assert.equal(this.removed.callCount, 0);
    assert.equal(this.moved.callCount, 0);
  });


  specify('Set changed elements', function() {
    this.target.set([4, 2, 5, 3]);

    this.updateTarget([0, 1, 2, 3, 4]);

    assert.deepEqual(this.target.get(), [0, 1, 2, 3, 4]);

    assert.equal(this.added.callCount, 2);
    assert.equal(this.removed.callCount, 1);
    assert.equal(this.moved.callCount, 2);
  });


  specify('Set repeating elements', function() {
    this.target.set([4, 4, 2, 5, 3, 2]);

    this.updateTarget([2, 2, 1, 4, 2, 4]);

    assert.deepEqual(this.target.get(), [2, 2, 1, 4, 2, 4]);
  });
});
