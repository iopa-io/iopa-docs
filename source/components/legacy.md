---
title: "Interoperating with Legacy"
description: "Using Legacy Middleware for Express or third party servers like Node.js `'http'`"
---
### Legacy Middleware

With the [`iopa-connect`](https://github.com/iopa-io/iopa-connect) package, `IOPA` servers can also call legacy Node HTTP middleware in the same chain with `app.use( function(req,res){ ... }  )`.    All the mapping between the IOPA property dictionary and the NODE req, res dictionaries done automatically without duplication of data.

### Legacy Servers
Many reference servers are written from the ground up and available already for IOPA including HTTP, CoAP, MQTT, UPNP, TCP, UDP, Stub Testing, WebKit-DarwinJavaScriptBridge, Chakra-WindowsJavasScriptBridge  etc..  However, in Node.js, existing servers that create a req res object (such as the built in `http` library) can also be used with a simple `require('iopa-connect')` bridge; similar bridges are available for node-coap, node-slack, azure-functions etc.