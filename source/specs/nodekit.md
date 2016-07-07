[![IOPA](./iopa.png)](http://iopa.io)
# IOPA Extension Specification: NodeKit
* Author : NodeKit Contributors 
* Copyright : 2015 Domabo. All Rights Reserved
* License : [Creative Commons Attribution ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/)
* Version : 1.4

## Contents

1. [Overview][1]

2. [Key usage guidelines][2]

3. [Naming conventions][3]

4. [Value conventions][4]

5. [Capabilities announcement and detection][5]

6. [nodeAppKit keys][6]

## 1. Overview

This document contains additional keys used by the nodekit.io reference application.


## 2\. Key usage guidelines

The Dictionary object can be used to extend the IOPA interface with additional functionality.

* All keys MUST be compared using Ordinal.

* All keys not defined in the IOPA standard are considered extension keys and are strictly optional.

* Implementers SHOULD clearly document what keys their component will populate, under what conditions, and the types and semantics of the associated values.

## 3\. Naming conventions

The Dictionary objects are open and mutable for storing arbitrary data. To avoid collisions between components, the following key naming conventions SHOULD be honored.

* Key names are Ordinal (case sensitive, culture insensitive) strings.


## 4\. Value conventions

The type of each value SHOULD be clearly documented by the implementer.

* Values MAY be of a type derived from the type specified in documentation, but the documentation SHOULD state under what conditions it is reasonable to expect such types to be available. Consumers may attempt to cast to more specific derived types (safely using is or as rather than an explicit cast), but SHOULD fall back to the documented base type wherever possible.

* Null values or empty strings SHOULD be treated the same as if the key were not present. Every key SHOULD have at least one defined value, even if the value is the string "true".

* Implementers SHOULD avoid populating keys associated with null values or empty strings, but SHOULD be tolerant of such values when retrieving data.

* Implementers MUST NOT overload a single key with multiple types (other than derived types as discussed above). If there are multiple possible representations, use separate keys to clearly identify them.

* Avoid using types that are likely to change signatures between versions.

* Prefer base types (e.g. int, string, etc.) or common types in the .NET framework that have existed for multiple releases (e.g. Stream).

* Values in the request Environment collection are assumed to be alive and accurate only for the lifetime of the request. Consumers SHOULD NOT retain or attempt to use values after a request has completed or failed. Where a value advertises a specific capability, that capability is only assumed to be available for that request instance and SHOULD be re-verified on future requests.

* Global capabilities or data SHOULD be communicated as described in section 5 below.

Where any specific value cleanup is required (e.g. Dispose), such cleanup is the responsibility of the component that originally added the value. This should be taken care of as the stack unwinds after a request has completed or failed.

## 5. Capabilities announcement and detection

It is important for applications to be able to determine if a specific feature is supported by the current server or middleware. The following pattern is recommended for announcing and detecting feature/extension support.

* At startup the server SHOULD create a `server.Capabilities` object dictionary in the startup Properties dictionary.

* This capabilities dictionary is for static capability details that do not change on a per-request basis.

* The same instance of the capabilities dictionary SHOULD also be included in each request environment dictionary.

* Each extension SHOULD add to the capabilities Dictionary a `nodeAppKit.Version` key with the associated string value of the latest version of that extension supported (e.g. 1.2).

* If extensions have defined additional keys used to indicate details, the implementer SHOULD add to the capabilities Dicitonary a `nodeAppKit.Support` Dictionary containing the detailed `nodeAppKit.FeatureDetail` keys and their associated values.

* Per-request feature keys and values should be included directly in the environment dictionary.

## 6\. nodekit keys

Keys and values listed here are those that are anticipated to be common across multiple implementations, but are not strictly required for basic operations.


| Object Name |  Type  | Startup | Request | Description |
| ---| --: | :-: | :-:| --- |
| io.nodekit.Version | String | X | X  | "1.0"|


   [1]: #1-overview
   [2]: #2-key-usage-guidelines
   [3]: #3-naming-conventions
   [4]: #4-value-conventions
   [5]: #5-capabilities-announcement-and-detection
   [6]: #6-nodekit-keys
  
