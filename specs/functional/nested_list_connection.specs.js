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

  before(function() {
    this.define('originList', new Transmitter.Nodes.ListNode());
    this.define('derivedList', new Transmitter.Nodes.ListNode());

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
  });


  specify('when origin list is updated', function() {
    const item1 = new ListItem('Origin item 1');
    const item2 = new ListItem('Origin item 2');

    Transmitter.startTransmission( (tr) => {
      item1.valueNode.set('Origin value 1').init(tr);
      item2.valueNode.set('Origin value 2').init(tr);
      this.originList.set([item1, item2]).init(tr);
    });
  });


  specify('then update is transmitted to derived list', function() {
    const derivedItems = this.derivedList.get();

    expect(derivedItems.map( (item) => item.name ))
      .to.deep.equal(['Derived item 1', 'Derived item 2']);
    expect(derivedItems.map( (item) => item.valueNode.get() ))
      .to.deep.equal(['Derived value 1', 'Derived value 2']);
  });
});
