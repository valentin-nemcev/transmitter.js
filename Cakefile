require 'shelljs/global'

bin = './node_modules/.bin'

mochaCmd = (files...) ->
  "#{bin}/mocha --colors --opts specs/mocha.opts #{files.join(' ')}"

unitSpecs = 'specs/unit.specs.coffee'
exampleSpecs = 'specs/examples.specs.coffee'

task 'build', ->
  exec "#{bin}/coffee -o build -c src"

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


task 'deps', ->
  invoke 'build'
  exec("#{bin}/madge -x '^(index|dom)' -t build | dot -Tpng", silent: yes)
    .output.to("deps.png")
  # exec "#{bin}/madge -x '^(index|dom)' -i deps.png build"
