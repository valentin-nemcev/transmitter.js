require 'shelljs/global'

bin = './node_modules/.bin'

mochaCmd = (args...) ->
  "#{bin}/mocha --bail --no-debug
    --colors --opts specs/mocha.opts #{args.join(' ')}"

unitSpecs = 'specs/unit.specs.coffee'
exampleSpecs = 'specs/examples.specs.coffee'

task 'build', ->
  exec "#{bin}/babel --only '*.es' src --out-dir build"
  exec "#{bin}/coffee -o build -c src"

task 'clean', ->
  rm '-rf', 'build/*'

option '-d', '--debug', 'Enable node debugger'
task 'specs', ->
  exec(mochaCmd(unitSpecs, exampleSpecs))

task 'specs:coverage', ->
  cmd =
    mochaCmd('specs/coverage.coffee', unitSpecs, exampleSpecs, '-R html-cov')
  exec(cmd, silent: yes).output.to('specs/coverage.html')

task 'specs:unit', ->
  exec(mochaCmd(unitSpecs))

task 'specs:examples', ->
  exec(mochaCmd(exampleSpecs))


task 'deps', ->
  invoke 'build'
  exec "#{bin}/madge -x '^(index|dom|assert|util)' -i deps.png build"
