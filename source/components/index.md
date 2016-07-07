---
title: "IOPA Context Record"
description: "A Key Value Property Dictionary that is the heart of the IOPA Specification"
---
### Context Dictionary

At the core, everything in IOPA can be represented with a single [string, object] key-value dictionary that we call the "Context" record.  The keys are generally well-defined from the IOPA specification, published open or proprietary extensions.    The context is typically used to represent the action 

For example an action that is to be applied to the state of a store can be described using the core three fields below (the base for any IOPA context).

| Key |  Description  | 
| --- | --- |
| "iopa.Method" | The method of a particular action that describes state |
| "iopa.Path" | The universal resource name path of a particular resource described by an action relative to the store base |
| "iopa.Body" | The state |

