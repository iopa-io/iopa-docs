title: About IOPA
description: Background behind the Organization and the Specification
---
IOPA is neither a protocol STANDARD nor a FRAMEWORK. Rather it is a PATTERN that defines a well-defined API (by convention not reference) between the broadest scope of Internet of Things (IoT) transport layers and application/device logic.  

The reference implementation (Internet Open Protocol Abstraction for JavaScript, Swift and C#) is a fabric that speeds development of applications that use the pattern, but is not necessary to implement or to interoperate with any other application, or middleware micro-service -- it just provides some very handy reference classes and constants for intellisense development, and provides a robust, tested example of the most common logic required (a dispatcher called the AppBuilder class, and a factory for creating IOPA context with automatic scope tracking). 

## INTERNET OPEN PROTOCOL ABSTRACTION
The Internet Open Protocol Abstraction (IOPA) is a specification and reference implementation of an API-first, Internet of Things (IoT) fabric.

### Internet

The pattern is intended for connected humans, animals, devices and things that generally use Internet protocols for communication.  

### Open

All aspects of IOPA are open-source and published under liberal licenses.    Contributions are welcome, and policies are in place to make this simple.    Equally it is an entirely extensible, so no one has to wait for IOPA to adopt a revision, they can simply register a unique namespace and add properties to the property bag for their application.  Over time we hope that all such additions are socialized into the open community.

### Protocol

The purpose of the pattern is to make many similar protocols easy to use.  There are no in-scope or out-of-scope hardware or information protocols, rather the pattern is focused on state, stores and transfer of state between stores, listeners and action creators.  Implementation is provided for some common protocols including TCP, UDP, HTTP, CoAP, MQTT, routing, and static resource serving. 

### Abstraction

IOPA is first and foremost a higher level abstraction of underlying transport capabilities.  A property bag or key-value dictionary is used so that no pre-compilation or libraries are needed to use IOPA.  


## INTERNET OF PROTOCOLS ASSOCIATION
The Internet of Protocols Association (also abbreviated IOPA) is the not-for-profit organizing body that maintains and publishes the *Internet Open Protocol Abstraction* specification.  See [Free and Open Source](doc:free-and-open-source) for more details.

IOPA started off as one-person GitHub side project, and currently includes as its members those individuals and organizations actively using the IOPA fabric and pattern.