import keysEqual from 'transmitter/keysEqual';

import {inspect} from 'util';

describe('Keys equal', function() {

  specify('simple values and arrays', function() {
    // From http://docs.couchdb.org/en/latest/couchapp/views/collation.html
    const getValues = () => [
      null,
      false,
      true,

      -1,
      0,
      1,
      3.5,

      'string1',
      'string2',

      [],
      ['string1'],
      ['string2'],
      ['string1', 'string2'],
      ['string1', 'string2', ['string3']],
      ['string1', 'string2', ['string4']],
    ];

    const left = getValues();
    const right = getValues();

    for (let l = 0; l < left.length; l++) {
      for (let r = 0; r < right.length; r++) {
        if (l === r) {
          expect(keysEqual(left[l], right[r]))
            .to.be.ok(
              `keysEqual(${inspect(left[l])}, ${inspect(right[r])})`
              + ' should be true'
            );
        } else {
          expect(keysEqual(left[l], right[r]))
            .to.not.be.ok(
              `keysEqual(${inspect(left[l])}, ${inspect(right[r])})`
              + ' should be false'
            );
        }
      }
    }
  });
});
