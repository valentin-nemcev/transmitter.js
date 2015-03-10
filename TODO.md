# TODO

* Remove use strict (needs custom compiler for mocha, browserify and npm)

* Unit tests should describe classes and their responsibilities
* Separate classes into topology and transmission and high-level api dirs
  * Find a name for high level api
* Rename `MessageChain` to `Transmission`
* Rename `send` and `enquire` to `receive/sendMessage` and `receive/sendQuery`
* Use Given-When-Then format for functional specs and examples
* Introduce functional specs
  * Write functional spec for message merging
  * Write functional spec for state querying
  * Write functional spec for
