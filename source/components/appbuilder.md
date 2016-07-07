---
title: "AppBuilder"
description: "A utility for constructing the application pipeline"
---
An application can be single AppFunc or can be chained with multiple middleware and application components each of which follow this exact same signature.

While you can chain the middleware using any proprietary technique, the specification describes an AppBuilder that provides a simple convention for chaining middleware together, and some syntax sugar to call any embedded servers by scheme string vs. by reference.

### Example Application

AppBuilder example application with server and middleware

```js
const middleware = function(context, next) {  ... } 
:

var app = new iopa.app();
app.use(middlewareServer);
app.use(middleware);
app.use(applicationFunction);

var server = app.createServer('tcp:');
server.listen({port: 80});
```