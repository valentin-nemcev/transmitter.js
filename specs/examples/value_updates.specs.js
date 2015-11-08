import * as Transmitter from 'transmitter';

class StatefulObject {
  constructor(name) {
    this.name = name;
  }
}

describe('Value updates preserve identity', function() {

  describe('for values', function() {

    beforeEach(function() {
      this.define('objectValue', new Transmitter.Nodes.Value());
      this.define('stringValue', new Transmitter.Nodes.Value());

      Transmitter.startTransmission( (tr) =>
        new Transmitter.Channels.BidirectionalChannel()
          .inBothDirections()
          .withOriginDerived(this.objectValue, this.stringValue)
          .withMatchOriginDerived( (object, string) =>
            (object != null) && string === object.name
          )
          .withMapOrigin( (object) => object.name )
          .withMapDerived( (string) => new StatefulObject(string) )
          .init(tr)
      );
    });


    specify(
      'state change message update target value instead of replacing',
      function() {
        this.object = new StatefulObject('nameA');
        this.objectValue.set(this.object);

        Transmitter.startTransmission( (tr) =>
          this.stringValue.set('nameA').init(tr)
        );

        expect(this.objectValue.get()).to.equal(this.object);
      });
  });


  describe('for lists', function() {

    beforeEach(function() {
      this.define('objectList', new Transmitter.Nodes.List());
      this.define('stringList', new Transmitter.Nodes.List());

      Transmitter.startTransmission( (tr) =>
        new Transmitter.Channels.BidirectionalChannel()
          .inBothDirections()
          .withOriginDerived(this.objectList, this.stringList)
          .withMatchOriginDerived( (object, string) =>
            (object != null) && string === object.name
          )
          .withMapOrigin( (object) => object.name )
          .withMapDerived( (string) => new StatefulObject(string) )
          .init(tr)
      );
    });


    specify(
      'state change message update target value instead of replacing',
      function() {
        this.objectA = new StatefulObject('nameA');
        this.objectB = new StatefulObject('nameB');
        this.objectList.set([this.objectA, this.objectB]);

        Transmitter.startTransmission( (tr) =>
          this.stringList.set(['nameB', 'nameA']).init(tr)
        );

        const objects = this.objectList.get();
        expect(objects[0]).to.equal(this.objectB);
        expect(objects[1]).to.equal(this.objectA);
      });
  });
});
