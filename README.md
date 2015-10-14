# Transmitter.js

Declarative data-binding JavaScript framework for web applications.
Transmitter.js helps you manage your application state, all the way from DOM to
backend storage, no matter how complex your application is.

**Transmitter.js is in early development stage and is not ready for production
yet**


## TODO

### Proposed usage examples

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


### Development tasks

* Refactor
  * Don't use context in isolated tests, use context in scenarios.
  * Refactor payload creation methods for regular nodes and dynamic channel
    nodes
  * Simplify payload transformation, always use merged and separated messages


* Implement
  * Better checks for message pass ordering in joint message
  * Update inner and outer nodes in separating channels

* Later
  * Remove use strict (needs custom compiler for mocha, browserify and npm)
