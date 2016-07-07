---
title: "Related Concepts"
description: "Relationship to other projects and architecture features"
---
## OTHER PROJECTS
OWIN, WCF, EXPRESS-JS, KOA, etc.

IOPA is a loose port of the [OWIN](http://owin.org) specification to expand the reach to Node.js servers but is language independent.  The pattern works for Node.js javascript (old versions including 0.12 and the latest at 6.0+),  browser-side javascript, Swift V2., Objective-C and Golang.   The core reference implementation is written in javascript for Node.js 6.x, with additional components available in Swift and C# for Darwin/Unix and Windows platforms respectively.

IOPA will feel familiar to those coming from HTTP frameworks such as WCF, Express or Koa with the well-defined `app.use()` pattern to build application pipelines.  However, IOPA takes these a step further and allows the very same middleware and applications to now server other protocols such as CoAP, MQTT, UPNP etc. without change.  

## SERVER AGNOSTIC

Published as open-source without dependence on any implementation or platform, the IOPA specs allow applications to be developed independently of the actual server (nGinX, IIS, Node.js, Katana, node-coap, iopa-mqtt, iopa-coap, iopa-http, etc.). 

## SERVERLESS READY

The pattern and reference implementation is particularly well-suited for Serverless cloud infrastructures such as AWS Lambda, Azure Functions, Google Cloud Functions and IBM OpenWhisk.   This is because each of these come with their own proprietary invocation patterns, but all essentially run micro-services that start based on well-defined trigger events.  Abstracting these events into a common format allows developers to create a common micro-service that runs without change in each of these environments, and means investments in common utility functions like authentication, authorization, logging, app analytics, etc. can all be done with the knowledge that these will likely work across platforms and even be reused for web, mobile etc.

## BOT READY

The pattern and reference implementation is particularly well-suited for Bot APIs such as Facebook Messenger, Amazon Alexa Skills, Microsoft Bot Framework, Google Now, and Whatsapp.   This is because each of these come with their own proprietary invocation patterns, but all essentially run micro-services that start based on conversational intent events.  Abstracting these events into a common format allows developers to create a common micro-service that runs without change in each of these environments.

## PATTERNS NOT LIBRARIES

Because it is a well-defined pattern that uses only base language features it is not even necessary to include this repository in any microservices that rely on it.  The entire pattern works using well-known string constants (published in the open-source [IOPA](https://github.com/iopa-io/iopa-spec) specification).  However, inclusion of this repository gives access to intellisense, constant optimization, etc.

## ECOSYSTEM 

A broad ecosystem of servers and middleware, such as routers and view engines, exist in the the [iopa-io](https://github.com/iopa-io] organization on GitHub.   We encourage any other middleware or implementations to be shared on GitHub with a name that starts `iopa-` as we will highlight active valued projects here.

## EMBEDDED IMPLEMENTATIONS

`iopa` powers `nodekit.io`, an open-source cross-platform IOPA certified user interface framework for Mac, Windows, iOS, Android, Node.js, etc.   Anything that can be written as a web application or REST application can be run on a single device with no coding changes, in javascript.      As such IOPA is for communicating with people, animals, devices and things.
.