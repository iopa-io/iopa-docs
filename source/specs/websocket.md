[![IOPA](./iopa.png)](http://iopa.io)
# IOPA Extension Specification: WebSockets
* Author : Internet of Protocols Alliance 
* Copyright : 2016 Internet of Protocols Alliance (IOPA) 
* License : [Creative Commons Attribution ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/)
* Version : 1.4

## Contents 

1. [Introduction](#1-introduction)

2. [Definitions](#2-definitions)

3. [Detection](#3-detection)

4. [Accept](#4-accept)

5. [Consumption](#5-consumption)

6. [Delegate Signature](#6-delegate-signature)

7. [Usage](#7-usage)


## 1. Introduction

This document outlines the recommended patterns for using WebSockets through the IOPA interface. It depends on IOPA v1.0 or later, the IOPA opaque streams extension, and uses the extension key mechanics as outlined in CommonKeys.


## 2\. Definitions

WebSocket \- Defined in RFC 6455, a web socket is a bidirectional, framed communication channel that uses HTTP for its initial handshake.

Opaque Stream - Some servers allow a request to take direct ownership of the underlying connection after the initial HTTP handshake. This gives the application access to a bidirectional opaque stream and the application is then responsible for employing its own protocol (e.g. WebSockets) to communicate with the client.


## 3\. Detection

In order for an application to use WebSockets it MUST first detect support for the extension.


### 3\.1 Startup

At startup the server SHOULD specify in the Properties server.Capabilities dictionary if WebSockets is supported (see the table below). If the application does not see support for WebSockets but does see support for Opaque Streams, it MAY insert a middleware to add WebSocket support.

| Object Name |  Description |
| ---| --- |
| websocket.Version| The string value 1.0 indicating version 1.0 of the IOPA WebSocket extension |

### 3\.2 Per Request

The WebSocket capable server or middleware inspects each request as it arrives to determine if it is WebSocket compatible (e.g. verb, headers, etc.). If so, it marks the request with a specific environment key (see the table below).

| Object Name |  Description |
| ---| --- |
| websocket.Accept | A WebSocketAccept Action added by the server if the current request supports WebSockets. See Delegate Signature |

## 4\. Accept

When an application sees a request that is marked as WebSocket capable and decides to accept to a WebSocket, it indicates this to the server or middleware by invoking the provided WebSocketAccept Action with parameters and a WebSocketFunc callback. This Action MUST immediately set the response status code to 101 and validate any input parameters and request state. The application then completes the AppFunc Task and allows the request pipeline to unwind.

Before invoking the WebSocketAccept Action the application MAY set the Sec-WebSocket-Protocol response header OR specify the subprotocol property in the parameters dictionary (see the table below), according to RFC 6455 Section 4.2.2 Step 5.5.

When the pipeline has unwound to the WebSocket server or middleware it SHOULD perform the requested accept. The WebSocket server or middleware MUST provide the necessary WebSocket response headers when performing the accept. Once the accept is complete the request has left HTTP processing and transitioned to WebSocket processing. The original Environment dictionary and its content are presumed invalid and a new one MUST be provided to the WebSocketFunc callback with the keys listed as required in the table below (see Consumption).

If the accept fails then the server or middleware SHOULD terminate the request. There is no guarantee that the WebSocketFunc provided by the application can or will be invoked in these scenarios, but the iopa.CallCancelled CancellationToken MUST be signaled if the callback wont be.

The WebSocketAccept parameters dictionary MAY be null if there are no parameters to pass in. If not null, it MUST be mutable and use ordinal key comparison.


| Object Name |  Description |
| ---| --- |
| websocket.SubProtocol | The negotiated protocol according to RFC 6455 Section 4.2.2 Step 5.5 |


In addition to these keys the host, server, middleware, application, etc. may add arbitrary data associated with the WebSocket Accept to the parameters dictionary. Guidelines for additional keys and a list of commonly defined keys can be found in CommonKeys.html.



## 5\. Consumption



When the server or middleware invoke the WebSocketFunc it provides a new WebSocket Environment dictionary (see Delegate Signature). The WebSocket Environment dictionary has the same requirements as the IOPA request Environment dictionary, namely that it MUST be non-null, mutable, use ordinal key comparison, and MUST contain the keys and values where listed as required in the table below.

| Required | Object Name |  Description |
|:-: | ---| --- |
| Yes | websocket.SendAsync | A Func used to send data. See Delegate Signature. |
| Yes | websocket.ReceiveAsync | A Func used to receive data. See Delegate Signature.. |
| Yes | websocket.CloseAsync | A Func used to close the output channel. See Delegate Signature. |
| Yes | websocket.Version | The string value 1.0 indicating version 1.0 of this IOPA WebSockets extension. |
| Yes | websocket.CallCancelled | A CancellationToken provided by the server to signal that the WebSocket has been canceled/aborted. |
| No | websocket.ClientCloseStatus | An optional int that may be set by the server or middleware when a close frame is received. |
| No | websocket.ClientCloseDescription | An optional string that may be set by the server or middleware when a close frame is received. |

In addition to these keys the host, server, middleware, application, etc. may add arbitrary data associated with the WebSocket context to the environment dictionary. Guidelines for additional keys and a list of commonly defined keys can be found in CommonKeys.html.

## 6\. Delegate Signature

The WebSocket signatures are follows:

`C#`

    using System;
    using System.Threading;
    using System.Threading.Tasks;
    using System.Collections.Generic;
 
    namespace iopa.WebSockets
    {
    using WebSocketAccept =
        Action
        <
            IDictionary<string, object>, // WebSocket Accept parameters
            Func // WebSocketFunc callback
            <
                IDictionary<string, object>, // WebSocket environment
                Task // Complete
            >
        >;
 
    using WebSocketFunc =
        Func
        <
            IDictionary<string, object>, // WebSocket Environment
            Task // Complete
        >;
 
    using WebSocketSendAsync =
        Func
        <
            ArraySegment<byte> /* data */,
            int /* messageType */,
            bool /* endOfMessage */,
            CancellationToken /* cancel */,
            Task
        >;
 
    using WebSocketReceiveAsync =
        Func
        <
            ArraySegment<byte> /* data */,
            CancellationToken /* cancel */,
            Task
            <
                Tuple
                <
                    int /* messageType */,
                    bool /* endOfMessage */,
                    int /* count */
                >
            >
        >;
 
    using WebSocketReceiveTuple =
        Tuple
        <
            int /* messageType */,
            bool /* endOfMessage */,
            int /* count */
        >;
 
    using WebSocketCloseAsync =
        Func
        <
            int /* closeStatus */,
            string /* closeDescription */,
            CancellationToken /* cancel */,
            Task
        >;
    }

## 7\. Usage

### 7.1 WebSocketAccept

 Provided by the server in the original environment dictionary for a WebSocket compatible request. This is invoked by the application to request the upgrade to WebSockets. The parameters dictionary may be null, but the WebSocketFunc callback MUST NOT be null. Invoking this will cause the response status code to be set to 101.

### 7.2 WebSocketFunc

This is the WebSocket application entry point. The server provides an Dictionary containing request information and the Send, Receive, and Close Funcs. On completion (success or fail), the application MUST complete or fail the returned Task or throw a synchronous exception.

### 7.3 WebSocketSendAsync

The application uses the WebSocketSendAsync Func to send data to the client. The application does not have direct control over frame boundaries, but it does control message boundaries. The values of messageType MUST match the opcodes defined in the RFC; E.g. 0x1 = Text, 0x2 = Binary, and 0x8 = Close. If SendAsync is used to send a close frame, the ArraySegment must either refer to a null or empty segment, or must contain the close status code and message as defined in RFC 6455 section 5.5.1. Ping and Pong control frames (0x9, 0xA) MAY be sent, but the underlying server or middleware MUST silently discard them if it does not permit them.

### 7.4 WebSocketReceiveAsync

 ReceiveAsync will return the current message type, if the full message was consumed, and the count of data copied to the given buffer. The values of messageType MUST match the opcodes defined in the RFC; 0x1 = Text, 0x2 = Binary, and 0x8 = Close. The server or middleware MUST perform any necessary un-masking of the data before returning it. If a close frame is received the count will be 0 and any close status or description will be set in the websocket environment dictionary under `websocket.ClientCloseStatus` and `websocket.ClientCloseDescription` if such values were sent by the client. Close data MUST NOT be copied to the users buffer. The server or middleware MUST NOT deliver Ping and Pong control frames (0x9, 0xA) to the application, they MUST be handled internally.

### 7.5 WebSocketCloseAsync

 Applications SHOULD follow the RFC guidelines regarding CloseAsync (section 5.5.1). The application SHOULD invoke CloseAsync when it is done sending outgoing data. The application MUST NOT attempt to send additional data after sending a close frame. The application MUST NOT attempt any further receives after a close frame is received. The application MAY abortively terminate the connection at any time by completing the WebSocketFunc return Task, optionally with an exception. The application SHOULD NOT invoke any of the delegates after it completes the returned task.

  

