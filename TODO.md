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
  * Payloads should represent change operations on nodes

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




Merging at node target
  -1 value
   0 value<

  change<
  no change

Queries
  To ensure one transmission per merge
    Fails because of lack of merging at node target (1)
  -1
  1

Queries affect whole network (2)

(1) automatically merge at node target using partial merge
(2) dont query at node target, just wait


Write spec
Merge at node target
  Change -1 priorities
    Remove rational priorities
    -1 needed for selecting message for merge (move to payload?)
    -1 needed for queue priority?
    -1 not needed for node sources and targets (node sources? queries at node
sources and targets?)
  Decide when no more messages will be received
    Query existing lines
    Ensure no more lines will be added (can't do this)
    When more lines are added, merge their messages and check that result doesn't change (otherwise raise an error)
      Handle line replacement, get message directly from origin channel node
  Automatically merge messages, selecting only one
    Assign priority to payloads, chose one with top priority, assert that it is
the only one
