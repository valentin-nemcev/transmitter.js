import * as Transmitter from 'transmitter';

class Item {
  constructor(tr, {tag, value} = {}) {
    this.tag = new Transmitter.Nodes.Value().set(tag).init(tr);
    this.value = new Transmitter.Nodes.Value().set(value).init(tr);
  }
}

describe('Grouping and sorting', function() {

  beforeEach(function() {
    this.define('itemList', new Transmitter.Nodes.List());
    this.define('itemsWithTags', new Transmitter.Nodes.List());

    Transmitter.startTransmission( (tr) => {
      const itemTags = new Transmitter.Nodes.List();
      new Transmitter.Channels.FlatteningChannel()
        .inForwardDirection()
        .withNestedAsOrigin(this.itemList, (item) => item.tag )
        .withFlat(itemTags)
        .init(tr);

      new Transmitter.Channels.SimpleChannel()
        .inForwardDirection()
        .fromSources(itemTags, this.itemList)
        .toTarget(this.itemsWithTags)
        .withTransform( ([tags, items]) => tags.zip(items) )
        .init(tr);
    });

    this.define('itemsByTags', new Transmitter.Nodes.SortedMap());


    this.items = [];
    Transmitter.startTransmission( (tr) => {
      this.items.push(
        new Item(tr, {tag: 'tagB', value: 'value1'}),
        new Item(tr, {tag: 'tagA', value: 'value2'}),
        new Item(tr, {tag: 'tagB', value: 'value3'})
      );
      this.itemList.set(this.items).init(tr);
    });
  });

  specify('indexes items by tag', function() {
    expect(this.itemsWithTags.getSize()).to.equal(3);

    expect(this.itemsWithTags.getAt(0)[0]).to.equal('tagB');
    expect(this.itemsWithTags.getAt(0)[1]).to.equal(this.items[0]);
    expect(this.itemsWithTags.getAt(1)[0]).to.equal('tagA');
    expect(this.itemsWithTags.getAt(1)[1]).to.equal(this.items[1]);
    expect(this.itemsWithTags.getAt(2)[0]).to.equal('tagB');
    expect(this.itemsWithTags.getAt(2)[1]).to.equal(this.items[2]);
  });

  specify('groups items by tag', function() {
    expect(this.itemsByTags.getSize()).to.equal(2);

    const tagAItemList = this.itemsByTags.getAt('tagA');
    const tagBItemList = this.itemsByTags.getAt('tagB');


    expect(tagAItemList.getSize()).to.equal(1);
    expect(tagBItemList.getSize()).to.equal(2);

    expect(tagAItemList.getAt(0)).to.equal(this.items[1]);
    expect(tagBItemList.getAt(0)).to.equal(this.items[0]);
    expect(tagBItemList.getAt(1)).to.equal(this.items[2]);
  });

});
