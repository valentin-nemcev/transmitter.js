require 'shelljs/global'


execMocha = (files...) ->
  exec './node_modules/mocha/bin/mocha -c --opts specs/mocha.opts ' \
    + files.join(' ')

# task 'specs', ->
#   exec mochaCmd

# task 'specs:unit', ->
#   exec mochaCmd + ' -ig Example:'

task 'specs:examples', ->
  execMocha 'specs/examples.specs.coffee'
