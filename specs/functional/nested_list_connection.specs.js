import * as Transmitter from 'transmitter';

class ListItem {
  inspect() { return '[' + this.name + ']'; }

  constructor(name) {
    this.name = name;
    this.valueNode = new Transmitter.Nodes.ValueNode();
  }
}


describe('Nested list connection', function() {

  function originToDerived(origin) {
    return origin.replace('Origin', 'Derived');
  }
  function derivedToOrigin(derived) {
    return derived.replace('Derived', 'Origin');
  }

  beforeEach(function() {
    this.define('originList', new Transmitter.Nodes.ListNode());
    this.define('derivedList', new Transmitter.Nodes.ListNode());

    // TODO: Use list updates
    const listChannel = new Transmitter.Channels.NestedBidirectionalChannel()
      .inBothDirections()
      .withOriginDerived(this.originList, this.derivedList)
      .withMapOrigin( (originItem) =>
        new ListItem(originToDerived(originItem.name))
      )
      .withMapDerived( (derivedItem) =>
        new ListItem(derivedToOrigin(derivedItem.name))
      )
      .withOriginDerivedChannel( (originItem, derivedItem) =>
        new Transmitter.Channels.BidirectionalChannel()
          .inBothDirections()
          .withOriginDerived(originItem.valueNode, derivedItem.valueNode)
          .withMapOrigin(originToDerived)
          .withMapDerived(derivedToOrigin)
      );

    Transmitter.startTransmission( (tr) =>
      listChannel.init(tr)
    );

    this.item1 = new ListItem('Origin item 1');
    this.item2 = new ListItem('Origin item 2');

    Transmitter.startTransmission( (tr) => {
      this.item1.valueNode.set('Origin value 1').init(tr);
      this.item2.valueNode.set('Origin value 2').init(tr);
      this.originList.set([this.item1, this.item2]).init(tr);
    });

  });


  specify('inner and outer initial update', function() {
    const derivedItems = this.derivedList.get();

    expect(derivedItems.map( (item) => item.name ))
      .to.deep.equal(['Derived item 1', 'Derived item 2']);
    expect(derivedItems.map( (item) => item.valueNode.get() ))
      .to.deep.equal(['Derived value 1', 'Derived value 2']);
  });


  specify('inner only update', function() {
    Transmitter.startTransmission( (tr) => {
      this.item1.valueNode.set('Origin value 1a').init(tr);
    });

    const derivedItems = this.derivedList.get();

    expect(derivedItems.map( (item) => item.valueNode.get() ))
      .to.deep.equal(['Derived value 1a', 'Derived value 2']);
  });
});
