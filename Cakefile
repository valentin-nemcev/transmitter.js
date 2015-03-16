require 'shelljs/global'

bin = './node_modules/mocha/bin'

execMocha = (files...) ->
  exec "#{bin}/mocha --colors --opts specs/mocha.opts #{files.join(' ')}"

unitSpecs = 'specs/unit.specs.coffee'
exampleSpecs = 'specs/examples.specs.coffee'

task 'specs', ->
  execMocha unitSpecs, exampleSpecs

task 'specs:unit', ->
  execMocha unitSpecs

task 'specs:examples', ->
  execMocha exampleSpecs
