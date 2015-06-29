# TODO


## Proposed usage examples

* Canceling todo item label change
* Setting empty todo label removes todo
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
  * Better names for node and connection source/target
  * Don't use context in isolated tests, use context in scenarios.
  * Better message merging (symmetrical querying and caching)

* Implement
  * Implement connection message precence with correct merging with regular
    messages and queries
  * Implement nested node querying after nested connection changes
  * Improve or remove query routing specs
  * Enforcing consistency for merging connections to channel nodes when
    intermediate node is updated (send query backwards prohibiting lower
    precedence updates)

* Later
  * Remove use strict (needs custom compiler for mocha, browserify and npm)
