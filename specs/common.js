// Enable here to support babel stack traces
// require('coffee-script/register');

require('source-map-support').install();
require('babel/register')({only: '*.es'});

// Enable here to support coffee stack traces
require('coffee-script/register');


Error.stackTraceLimit = 15;

const chai = require('chai');

global.expect = chai.expect;

global.sinon = require('sinon');

require('mocha-sinon');

const sinonChai = require('sinon-chai');

chai.use(sinonChai);

chai.use(function() {
  const Assertion = chai.Assertion;
  return Assertion.addMethod('calledWithSame', function() {
    const match = global.sinon.match;
    return this.calledWith(match.same.apply(match, arguments));
  });
});
