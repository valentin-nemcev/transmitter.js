import * as Transmitter from 'transmitter';


describe('Bidirectional state message routing', function() {

  beforeEach(function() {
    this.define('tagSet', new Transmitter.Nodes.ValueNode());
    this.tagSet.set(new Set());

    this.define('tagSortedList', new Transmitter.Nodes.ValueNode());
    Transmitter.startTransmission( (tr) =>
      new Transmitter.Channels.BidirectionalChannel()
        .inBothDirections()
        .withOriginDerived(this.tagSet, this.tagSortedList)
        .withMapOrigin( (tags) => Array.from(tags).sort() )
        .withMapDerived( (tags) => new Set(tags) )
        .init(tr)
    );

    this.define('tagJSON', new Transmitter.Nodes.ValueNode());
    Transmitter.startTransmission( (tr) =>
      new Transmitter.Channels.BidirectionalChannel()
        .inBothDirections()
        .withOriginDerived(this.tagSortedList, this.tagJSON)
        .withMapOrigin( (tags) => JSON.stringify(tags) )
        .withMapDerived( (tagJSON) => tagJSON && JSON.parse(tagJSON) )
        .init(tr)
    );

    this.define('tagInput', new Transmitter.Nodes.ValueNode());
    Transmitter.startTransmission( (tr) =>
      new Transmitter.Channels.BidirectionalChannel()
        .inBothDirections()
        .withOriginDerived(this.tagSortedList, this.tagInput)
        .withMapOrigin( (tags) => (tags != null ? tags : []).join(', ') )
        .withMapDerived( (tagStr) => tagStr.split(/\s*,\s*/) )
        .init(tr)
    );
  });


  specify(
    'when derived node is queried, it gets update from origin node',
    function() {
      this.tagSet.set(new Set(['tagB', 'tagA']));

      Transmitter.startTransmission( (tr) => {
        this.tagJSON.query(tr);
        this.tagInput.query(tr);
      });

      expect(this.tagJSON.get()).to.equal('["tagA","tagB"]');
      expect(this.tagInput.get()).to.equal('tagA, tagB');
    });


  specify(
    'when origin node is updated, change is transmitted to derived nodes',
    function() {
      Transmitter.startTransmission( (tr) =>
        this.tagSet.set(new Set(['tagB', 'tagA'])).init(tr)
      );

      expect(this.tagJSON.get()).to.equal('["tagA","tagB"]');
      expect(this.tagInput.get()).to.equal('tagA, tagB');
    });


  specify(
    'when derivied node is updated, ' +
     'change is transmitted to origin and other derived nodes',
    function() {
      Transmitter.startTransmission( (tr) =>
        this.tagInput.set('tagA, tagB').init(tr)
      );

      expect(Array.from(this.tagSet.get())).to.deep.equal(['tagA', 'tagB']);
      expect(this.tagJSON.get()).to.equal('["tagA","tagB"]');
    });


  specify(
    'when intermediate node is updated, ' +
    'change is transmitted to origin and derived nodes',
    function() {
      Transmitter.startTransmission( (tr) =>
        this.tagSet.set(['tagA', 'tagB']).init(tr)
      );

      expect(Array.from(this.tagSet.get())).to.deep.equal(['tagA', 'tagB']);
      expect(this.tagJSON.get()).to.equal('["tagA","tagB"]');
      expect(this.tagInput.get()).to.equal('tagA, tagB');
    });
});
