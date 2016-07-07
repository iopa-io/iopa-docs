---
title: "AppFunc Middleware"
description: "A middleware or application method signature of all things IOPA"
---
An IOPA application is simply a `function(context, next)` that we call an `AppFunc`.  It provides a single REST-like IOPA context for each request, where it is easy to access all the HTTP/COAP parameters  (path, method, body etc.).    A next() function is typically provided to represent other processing that should occur on the same context record.

```js
function(context, next) 
{
 // do something with context object
context.response.write('hello world');
     
 // execute pipeline
return next();
}
```


### Asynchronous Promises

Each AppFunc returns a tasks/ or promise to allow for asynchronous or event-based programming without "callback hell", and for full compatibility with the upcoming ES7 async/await functionality, C# tasks etc.