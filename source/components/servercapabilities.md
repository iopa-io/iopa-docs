---
title: "Server.Capabilities"
description: "A special key within every IOPA Context record"
---
### Server Capabilities Key

The `"Server.Capabilities"` key exists in every IOPA context record.

```js
context['server.Capabilities'] =  {
  "urn:io.iopa:demoapp:demomiddleware": "
    { 
      "demo.salutation": "hello world"
    }
}
```

It is used to store application level parameters or state that is either constant across the invocation of an application (e.g., location of certain functions or utility functions) OR is necessary during the individual processing of a Context record for the lifetime of the request (typically milliseconds).

The child values of this key are each uniquely identified by a URN associated with a particular application, middleware or IOPA extension.   The value of any grandchild keys are up to the application, middleware, or extension, but are useful way to pass configuration data and other application constant data that is not mutated or appropriate for the stores.  It can be added to for each Context record as a temporary memory that persists exactly for the lifetime of a context record and is not shared with other context records.

Most applications state should be handled in the stores (outside of the purview of IOPA, but mutated by IOPA action context records).   However just as the Context record is a form of temporary state that can be mutated by IOPA middleware (but doesnt persist unless the middleware has deliberate side-effects), the Server.Capabiltiies subsection is a special area that is hyrdrated at application start (or restart) and copied across (two layers deep) to each Context record.  

Any pre-configuration made in the top two levels of Server.Capabilities (e.g., the value itself or child object kept in the value) is generally copied to each Context records (policy can be changed by the specific implementation), but any changes below this are made available for temporary state for the lifetime of a single Context record only.

A context record including all the values in this key is disposed when the outermost AppFunc that invokes it is fulfilled.

### Server Farm Considerations

The Server.Capabilities is a useful area for memory that must be copied to each server in server farm, and to be dehyrdated and re-hydrated across long running processes.  It is currently the only key in the specification that has such special persistence requirements.