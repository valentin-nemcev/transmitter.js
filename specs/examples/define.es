/* eslint-env mocha, chai */
/* global expect */
/* eslint-disable padded-blocks */

before(function() {
  this.define = function(name, value) {
    value.inspect = () => name;
    this[name] = value;
    return value;
  };
});
