require 'shelljs/global'

bin = './node_modules/mocha/bin'

mochaCmd = (files...) ->
  "#{bin}/mocha --colors --opts specs/mocha.opts #{files.join(' ')}"

unitSpecs = 'specs/unit.specs.coffee'
exampleSpecs = 'specs/examples.specs.coffee'

task 'specs', ->
  exec(mochaCmd unitSpecs, exampleSpecs)

task 'specs:coverage', ->
  cmd =
    mochaCmd('specs/coverage.coffee', unitSpecs, exampleSpecs, '-R html-cov')
  exec(cmd, silent: yes).output.to('specs/coverage.html')

task 'specs:unit', ->
  exec(mochaCmd(unitSpecs))

task 'specs:examples', ->
  exec(mochaCmd(exampleSpecs))
