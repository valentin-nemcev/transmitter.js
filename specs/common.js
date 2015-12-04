require('source-map-support').install();
require('babel/register')();

Error.stackTraceLimit = 15;

const chai = require('chai');

global.expect = chai.expect;
global.assert = chai.assert; // Assert doesn't work because of dirty-chai

global.sinon = require('sinon');

require('mocha-sinon');

chai.use(require('dirty-chai'));
chai.use(require('sinon-chai'));

chai.use(function() {
  chai.Assertion.addMethod('calledWithSame', function() {
    const match = global.sinon.match;
    this.calledWith(match.same.apply(match, arguments));
  });
});
