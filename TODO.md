# TODO


## Proposed usage examples

* Button with enabled or disabled states
* Serialized value with on-demand transmission
* Select box connection
* Changing model list order preserving view state
* Adding model to list without full view refresh
* Managing list ordering with list entries
* Display some property of each model in a list with repetitions
* Two-way serialization of model list with self-references
* Two-way serialization of nested models
* View types dependent on model property
* Reusing same view with different models
* Accepting or canceling changes with intermediate models


## Development tasks

* Refactor
  * Move payload creation into message
  * Better names for node and connection source/target
  * Don't use context in isolated tests, use context in scenarios.
  * Adding messages and queries to and from nodes
  * Message and query interaction with node sources and targets
  * Better message merging (symmetrical querying and caching)

* Implement
  * Node source and targets querying and queueing
  * Queue prioritization by directions
  * Queue prioritization by nesting level

* Later
  * Remove use strict (needs custom compiler for mocha, browserify and npm)
