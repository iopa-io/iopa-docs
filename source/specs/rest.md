[![IOPA](./iopa.png)](http://iopa.io)
# IOPA Core Specification: REST Keys
* Author : Internet of Protocols Alliance 
* Copyright : 2016 Internet of Protocols Alliance (IOPA) 
* License : [Creative Commons Attribution ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/)
* Version : 1.4

## Contents 

1. [Introduction](#1-introduction)

2. [Definitions](#2-definitions)

3. [Detection](#3-detection)

4. [Upgrade](#4-upgrade)

5. [Consumption](#5-consumption)

6. [Delegate Signature](#6-delegate-signature)

7. [Usage](#7-usage)


## 1. Introduction


This document outlines the recommended patterns for using opaque streams through the IOPA interface. It depends on IOPA version 1.0 or later, and uses the extension key mechanics as outlined in CommonKeys.

## 2\. Definitions

Opaque Streams or Opaque Mode - Some servers allow a request to take direct ownership of the underlying connection after the initial HTTP handshake. This gives the application access to a bidirectional communication channel and the application is then responsible for employing its own protocol (e.g. WebSockets) to communicate with the client. Normally this involves sending a 101 response status code.

## 3\. Detection

In order for an application to use Opaque it MUST first detect support for the extension.

### 3\.1 Startup

At startup the server SHOULD specify in the Properties server.Capabilities dictionary if Opaque is supported (see the table below). If the application does not see support for Opaque but does see support for Opaque Streams, it MAY insert a middleware to add Opaque support.


### 3\.2 Per Request

The Opaque capable server or middleware inspects each request as it arrives to determine if it is Opaque compatible (e.g. verb, headers, etc.). If so, it marks the request with a specific environment key (see the table below).

| Object Name |  Description |
| ---| --- |
| opaque.Upgrade| An OpaqueUpgrade Action added by the server if the current request supports Opaque. See Delegate Signature |

## 4\. Upgrade

When an application sees a request that is marked as Opaque capable and decides to upgrade to Opaque, it indicates this to the server or middleware by invoking the provided OpaqueUpgrade Action with parameters and an OpaqueFunc callback. This Action MUST immediately set the response status code to 101 and validate any input parameters and request state. The application then completes the AppFunc Task and allows the request pipeline to unwind.

When the pipeline has unwound to the Opaque server or middleware it SHOULD perform the requested upgrade. Once the upgrade is complete the request has left HTTP processing and transitioned to Opaque processing. The original Environment dictionary and its content are presumed invalid and a new one MUST be provided to the OpaqueFunc callback with the keys listed as required in the table below (see Consumption).

If the upgrade fails then the server or middleware SHOULD terminate the request. There is no guarantee that the OpaqueFunc provided by the application can or will be invoked in these scenarios, but the iopa.CallCancelled CancellationToken MUST be signaled if the callback wont be.

The OpaqueUpgrade parameters dictionary MAY be null if there are no parameters to pass in. If not null, it MUST be mutable and use ordinal key comparison.

In addition to these keys the host, server, middleware, application, etc. may add arbitrary data associated with the Opaque Upgrade to the parameters dictionary. Guidelines for additional keys and a list of commonly defined keys can be found in CommonKeys.

## 5\. Consumption

When the server or middleware invoke the OpaqueFunc it provides a new Opaque Environment dictionary (see Delegate Signature). The Opaque Environment dictionary has the same requirements as the IOPA request Environment dictionary, namely that it MUST be non-null, mutable, use ordinal key comparison, and MUST contain the keys and values where listed as required in the table below.

| Required | Object Name |  Description |
|:-: | ---| --- |
| Yes | opaque.Stream | A duplex Stream for sending and receiving data. |
| Yes | opaque.Version | The string value 1.0 indicating version 1.0 of this IOPA Opaque extension. |
| Yes | opaque.CallCancelled | A CancellationToken provided by the server to signal that opaque streaming has been canceled/aborted. |

In addition to these keys the host, server, middleware, application, etc. may add arbitrary data associated with the Opaque context to the environment dictionary. Guidelines for additional keys and a list of commonly defined keys can be found in CommonKeys

## 6\. Delegate Signature

The opaque stream body delegate signature is as follows:

`C#`

    using OpaqueUpgrade =
        Action
        <
            IDictionary<string, object>, // Parameters
            Func // OpaqueFunc callback
            <
                IDictionary<string, object>, // Opaque environment
                Task // Complete
            >
        >;
 
    using OpaqueFunc =
        Func
        <
            IDictionary<string, object>, // Opaque Environment
            Task // Complete
        >;

## 7\. Usage

Once the upgrade is complete the consumer operates their own protocol (e.g. WebSockets) over the given Stream. On completion (success or fail), the application MUST complete or fail the returned Task. The consumer SHOULD NOT close the given Stream, the provider (the server or middleware) owns these and is responsible for any cleanup on completion of the OpaqueFunc. The application SHOULD NOT continue to access the Stream once it completes the returned task.

If the `oapaque.CallCancelled` CancellationToken is cancelled, the application SHOULD promptly terminate processing and complete the returned Task.

