import * as Transmitter from 'transmitter';

class Item {
  constructor(tr, {tag, value} = {}) {
    this.tagNode = new Transmitter.Nodes.ValueNode().set(tag).init(tr);
    this.valueNode = new Transmitter.Nodes.ValueNode().set(value).init(tr);
  }
}

describe('Grouping', function() {

  beforeEach(function() {
    this.define('itemSet', new Transmitter.Nodes.OrderedSetNode());
    this.define('tagNodeByItem', new Transmitter.Nodes.OrderedMapNode());
    this.define('tagByItemMap', new Transmitter.Nodes.OrderedMapNode());
    this.define('itemsByTagMap', new Transmitter.Nodes.OrderedMapNode());
    this.define('itemSetByTagMap', new Transmitter.Nodes.OrderedMapNode());

    Transmitter.startTransmission( (tr) => {

      new Transmitter.Channels.BidirectionalChannel()
        .inForwardDirection()
        .withOriginDerived(this.itemSet, this.tagNodeByItem)
        .updateMapByValue()
        .withMapOrigin( (item) => item.tagNode )
        .init(tr);

      new Transmitter.Channels.FlatteningChannel()
        .inForwardDirection()
        .withNestedAsOrigin(this.tagNodeByItem)
        .withFlat(this.tagByItemMap)
        .init(tr);

      new Transmitter.Channels.BidirectionalChannel()
        .inForwardDirection()
        .withOriginDerived(this.tagByItemMap, this.itemsByTagMap)
        .withTransformOrigin(
          (payload) => payload.groupKeysByValue()
        )
        .init(tr);

      new Transmitter.Channels.BidirectionalChannel()
        .inForwardDirection()
        .withOriginDerived(this.itemsByTagMap, this.itemSetByTagMap)
        .updateMapByKey()
        .withMapOrigin( () => new Transmitter.Nodes.OrderedSetNode() )
        .init(tr);

      new Transmitter.Channels.FlatteningChannel()
        .inForwardDirection()
        .withTransformFlat(
          (payload) => payload.unflattenToSequences()
        )
        .withFlat(this.itemsByTagMap)
        .withNestedAsDerived(this.itemSetByTagMap)
        .init(tr);
    });

    this.items = [];
    Transmitter.startTransmission( (tr) => {
      this.items.push(
        new Item(tr, {tag: 'tagB', value: 'value1'}),
        new Item(tr, {tag: 'tagA', value: 'value2'}),
        new Item(tr, {tag: 'tagB', value: 'value3'})
      );
      this.itemSet.set(this.items).init(tr);
    });
  });

  specify('indexes items by tag', function() {
    expect(this.tagByItemMap.getSize()).to.equal(3);

    expect(this.tagByItemMap.getAt(this.items[0])).to.equal('tagB');
    expect(this.tagByItemMap.getAt(this.items[1])).to.equal('tagA');
    expect(this.tagByItemMap.getAt(this.items[2])).to.equal('tagB');
  });

  specify('groups items by tag', function() {
    expect(this.itemSetByTagMap.getSize()).to.equal(2);

    const tagAItemSet = this.itemSetByTagMap.getAt('tagA');
    const tagBItemSet = this.itemSetByTagMap.getAt('tagB');

    expect(tagAItemSet.getSize()).to.equal(1);
    expect(tagBItemSet.getSize()).to.equal(2);

    expect(tagAItemSet.get()[0]).to.equal(this.items[1]);
    expect(tagBItemSet.get()[0]).to.equal(this.items[0]);
    expect(tagBItemSet.get()[1]).to.equal(this.items[2]);
  });

});
