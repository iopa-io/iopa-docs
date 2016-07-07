---
title: "Getting Started with IOPA"
description: "This page will help you get started with IOPA. You'll be up and running in a jiffy!"
---
Add `iopa` to your Node.js project
```shell
npm install iopa --save
```

Create a simple Hello World application
```js
const iopa = require('iopa')
var app = new iopa.App()

app.use(function (context, next) 
{
   context.log.info("HELLO WORLD" + context.toString());
   return next()
});

var demo = app.build();
var context = app.createContext();  // typically done within an HTTP, CoAP or MQTT server

context.using(demo);     // the using automatically disposes of the context"
```