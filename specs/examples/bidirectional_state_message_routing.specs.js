import Transmitter from 'transmitter';


describe('Bidirectional state message routing', function() {

  beforeEach(function() {
    this.define('tagSet', new Transmitter.Nodes.Variable());
    this.tagSet.set(new Set());

    this.define('tagSortedList', new Transmitter.Nodes.Variable());
    Transmitter.startTransmission( (tr) =>
      new Transmitter.Channels.BidirectionalChannel()
        .inBothDirections()
        .withOriginDerived(this.tagSet, this.tagSortedList)
        .withMapOrigin( (tags) => Array.from(tags).sort() )
        .withMapDerived( (tags) => new Set(tags) )
        .init(tr)
    );

    this.define('tagJSON', new Transmitter.Nodes.Variable());
    Transmitter.startTransmission( (tr) =>
      new Transmitter.Channels.BidirectionalChannel()
        .inBothDirections()
        .withOriginDerived(this.tagSortedList, this.tagJSON)
        .withMapOrigin( (tags) => JSON.stringify(tags) )
        .withMapDerived( (tagJSON) => tagJSON && JSON.parse(tagJSON) )
        .init(tr)
    );

    this.define('tagInput', new Transmitter.Nodes.Variable());
    return Transmitter.startTransmission( (tr) =>
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
        this.tagJSON.queryState(tr);
        this.tagInput.queryState(tr);
      });

      expect(this.tagJSON.get()).to.equal('["tagA","tagB"]');
      expect(this.tagInput.get()).to.equal('tagA, tagB');
    });


  specify(
    'when origin node is updated, change is transmitted to derived nodes',
    function() {
      Transmitter.startTransmission( (tr) =>
        this.tagSet.init(tr, new Set(['tagB', 'tagA']))
      );

      expect(this.tagJSON.get()).to.equal('["tagA","tagB"]');
      expect(this.tagInput.get()).to.equal('tagA, tagB');
    });


  specify(
    'when derivied node is updated, ' +
     'change is transmitted to origin and other derived nodes',
    function() {
      Transmitter.startTransmission( (tr) =>
        this.tagInput.init(tr, 'tagA, tagB')
      );

      expect(Array.from(this.tagSet.get())).to.deep.equal(['tagA', 'tagB']);
      expect(this.tagJSON.get()).to.equal('["tagA","tagB"]');
    });


  specify(
    'when intermediate node is updated, ' +
    'change is transmitted to origin and derived nodes',
    function() {
      Transmitter.startTransmission( (tr) =>
        this.tagSet.init(tr, ['tagA', 'tagB'])
      );

      expect(Array.from(this.tagSet.get())).to.deep.equal(['tagA', 'tagB']);
      expect(this.tagJSON.get()).to.equal('["tagA","tagB"]');
      expect(this.tagInput.get()).to.equal('tagA, tagB');
    });
});
