import * as Transmitter from 'transmitter';

class Item {
  constructor(tr, {tag, value} = {}) {
    this.tag = new Transmitter.Nodes.Value().set(tag).init(tr);
    this.value = new Transmitter.Nodes.Value().set(value).init(tr);
  }
}

describe.skip('Grouping and sorting', function() {

  beforeEach(function() {
    this.define('itemList', new Transmitter.Nodes.List());
    this.define('itemWithTagList', new Transmitter.Nodes.List());

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
        .toTarget(this.itemWithTagList)
        .withTransform( ([tags, items]) => tags.zip(items) )
        .init(tr);
    });

    this.define('itemListsByTag', new Transmitter.Nodes.SortedMap());

    this.define(
      'itemListsByTagDynamicChannelNode',
      new Transmitter.ChannelNodes.DynamicMapChannelValue(
        'targets',
        (targets) =>
          new Transmitter.Channels.SimpleChannel()
            .inForwardDirection()
            .fromSource(this.itemWithTagList)
            .toDynamicTargets(targets)
            .withTransform(
              (itemsWithTags, tagLists) =>
                itemsWithTags.groupUnflatten().coerceSize(tagLists)
            )
      )
    );

    Transmitter.startTransmission( (tr) => {
      new Transmitter.Channels.SimpleChannel()
        .inForwardDirection()
        .fromSource(this.itemWithTagList)
        .toTarget(this.itemListsByTag)
        .withTransform(
          (itemsWithTags) =>
            itemsWithTags.group().map( () => new Transmitter.Nodes.List() )
        )
        .init(tr);

      new Transmitter.Channels.NestedSimpleChannel()
        .fromSource(this.itemListsByTag)
        .toChannelTarget(this.itemListsByTagDynamicChannelNode)
        .withTransform( (payload) => payload )
        .init(tr);
    });

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
    expect(this.itemWithTagList.getSize()).to.equal(3);

    expect(this.itemWithTagList.getAt(0)[0]).to.equal('tagB');
    expect(this.itemWithTagList.getAt(0)[1]).to.equal(this.items[0]);
    expect(this.itemWithTagList.getAt(1)[0]).to.equal('tagA');
    expect(this.itemWithTagList.getAt(1)[1]).to.equal(this.items[1]);
    expect(this.itemWithTagList.getAt(2)[0]).to.equal('tagB');
    expect(this.itemWithTagList.getAt(2)[1]).to.equal(this.items[2]);
  });

  specify('groups items by tag', function() {
    expect(this.itemListsByTag.getSize()).to.equal(2);

    const tagAItemList = this.itemListsByTag.getAt('tagA');
    const tagBItemList = this.itemListsByTag.getAt('tagB');


    expect(tagAItemList.getSize()).to.equal(1);
    expect(tagBItemList.getSize()).to.equal(2);

    expect(tagAItemList.getAt(0)).to.equal(this.items[1]);
    expect(tagBItemList.getAt(0)).to.equal(this.items[0]);
    expect(tagBItemList.getAt(1)).to.equal(this.items[2]);
  });

});
