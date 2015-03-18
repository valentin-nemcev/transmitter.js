# TODO

* Remove use strict (needs custom compiler for mocha, browserify and npm)

* Better message merging (symmetrical querying and caching)

* Unit tests should describe units and their responsibilities
* Replace recursive binding with centralized in binding builder (maybe)

* Make query and message symmetrical
* Rename `send` and `enquire` to `receive/sendMessage` and `receive/sendQuery`

* Introduce functional specs
  * Write functional spec for message merging
  * Write functional spec for state querying
  * Write functional spec for message transmission

* Use Given-When-Then format for functional specs and examples
  * Use mocha-steps (maybe)
