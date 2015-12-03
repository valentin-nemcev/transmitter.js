import compareKeys from 'transmitter/compareKeys';

describe('Compare keys', function() {

  specify('simple values and arrays', function() {
    // From http://docs.couchdb.org/en/latest/couchapp/views/collation.html
    const values = [
      null,
      false,
      true,

      -1,
      0,
      1,
      2,
      3.5,
      4,
      20,
      30,

      'A',
      'B',
      'a',
      'aa',
      'b',
      'ba',
      'bb',

      [],
      ['a'],
      ['b'],
      ['b', 'c'],
      ['b', 'c', 'a'],
      ['b', 'd'],
      ['b', 'd', 'e'],

      ['b', 'd', ['a']],
      ['b', 'd', ['a', 'b']],
    ];

    const sorted = values.slice().reverse().sort(compareKeys);

    expect(sorted).to.deep.equal(values);
  });
});
