import Transmitter from 'transmitter';

class ListItem {
  inspect() { return '[' + this.name + ']'; }

  constructor(name) {
    this.name = name;
    this.valueVar = new Transmitter.Nodes.Variable();
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
    this.define('originList', new Transmitter.Nodes.List());
    this.define('derivedList', new Transmitter.Nodes.List());

    const listChannel = new Transmitter.Channels.ListChannel()
      .withOrigin(this.originList)
      .withMapOrigin( (originItem) =>
        new ListItem(originToDerived(originItem.name))
      )
      .withDerived(this.derivedList)
      .withMapDerived( (derivedItem) =>
        new ListItem(derivedToOrigin(derivedItem.name))
      )
      .withOriginDerivedChannel( (originItem, derivedItem) =>
        new Transmitter.Channels.VariableChannel()
          .withOrigin(originItem.valueVar)
          .withMapOrigin(originToDerived)
          .withDerived(derivedItem.valueVar)
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
      item1.valueVar.init(tr, 'Origin value 1');
      item2.valueVar.init(tr, 'Origin value 2');
      this.originList.init(tr, [item1, item2]);
    });
  });


  specify('then update is transmitted to derived list', function() {
    const derivedItems = this.derivedList.get();

    expect(derivedItems.map( (item) => item.name ))
      .to.deep.equal(['Derived item 1', 'Derived item 2']);
    expect(derivedItems.map( (item) => item.valueVar.get() ))
      .to.deep.equal(['Derived value 1', 'Derived value 2']);
  });
});
