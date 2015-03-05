require 'shelljs/global'


mochaCmd = './node_modules/mocha/bin/mocha -c --opts specs/mocha.opts specs'

task 'specs', ->
  exec mochaCmd

task 'specs:unit', ->
  exec mochaCmd + ' -ig Example:'
