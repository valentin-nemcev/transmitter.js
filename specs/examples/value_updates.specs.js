import Transmitter from 'transmitter';

class StatefulObject {
  constructor(name) {
    this.name = name;
  }
}

describe('Value updates preserve identity', function() {

  describe('for variables', function() {

    beforeEach(function() {
      this.define('objectVar', new Transmitter.Nodes.Variable());
      this.define('stringVar', new Transmitter.Nodes.Variable());

      Transmitter.startTransmission( (tr) =>
        new Transmitter.Channels.BidirectionalChannel()
          .inBothDirections()
          .withOriginDerived(this.objectVar, this.stringVar)
          .withMatchDerivedOrigin( (string, object) =>
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
        this.objectVar.set(this.object);

        Transmitter.startTransmission( (tr) =>
          this.stringVar.init(tr, 'nameA')
        );

        expect(this.objectVar.get()).to.equal(this.object);
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
          .withMatchDerivedOrigin( (string, object) =>
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
          this.stringList.init(tr, ['nameB', 'nameA'])
        );

        const objects = this.objectList.get();
        expect(objects[0]).to.equal(this.objectB);
        expect(objects[1]).to.equal(this.objectA);
      });
  });
});
