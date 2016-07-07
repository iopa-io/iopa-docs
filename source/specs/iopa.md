[![IOPA](./iopa.png)](http://iopa.io)
# IOPA Core Specification 1.4
* Author : Internet of Protocols Alliance 
* Copyright : 2016 Internet of Protocols Alliance (IOPA) 
* License : [Creative Commons Attribution ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/)
* Version : 1.4

## Contents

1\. [Overview][1]

2\. [Definitions][2]

3\. [Request Execution][3]

3.1. [Application Delegate][4]

3.2. [Environment][5]

3.3. [Headers][6]

3.4. [Request Body][7]

3.5. [Response Body][8]

3.6. [Request Lifetime][9]

4\. [Application Startup][10]

5\. [URI Reconstruction][11]

5.1. [URI Scheme][12]

5.2. [Hostname][13]

5.3. [Paths][14]

5.4. [URI Reconstruction Algorithm][15]

5.5. [Percent-encoding][16]

6\. [Error Handling][17]

6.1. [Application Errors][18]

6.2. [Server Errors][19]

7\. [Versioning][20]

8\. [Extensions][201]

9\. [Real World Usage][202]

## 1\. Overview

This document defines the Open Web Interface for Node.js (IOPA), a standard framework for REST servers for io.js, Node.js and backwards compatible with .NET.  

IOPA is targeted for multiple transport providers including HTTP, COAP and MQTT servers, and can be a drop-in replacement for existing frameworks such as Connect/Express on Node.js.   It defines a standard way that application/device logic can rely on REST server capabilities without being tied to any one transport (http, express, koa, node-coap, mosca, etc.) 

IOPA is defined in terms of a delegate structure. There is no assembly. Implementing either the host or application side the IOPA spec does not introduce a dependency to a project.

In this document, the Node.js `function` and C# `Action`/`Func` syntax is used to notate some delegate structures.   However, the delegate structure could be equivalently represented with other native functions, CLR interfaces, or named delegates. This is by design; when implementing IOPA, choose a delegate representation that works for you and your stack.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119][21].


## 2\. Definitions

This document refers to the following software actors:

* Server – The REST server (typically HTTP, COAP or MQTT) that directly communicates with the client and then uses IOPA semantics to process requests. Servers may require an adapter layer that converts to IOPA semantics.

* Framework – A self-contained component based on IOPA exposing its own object model or API that applications may use to facilitate request processing. Frameworks may require an adapter layer that converts from IOPA semantics.

* Application – A specific application or device logic, possibly built on top of a Web Framework, which is run using IOPA compatible Servers.

* Middleware – Pass through components that form a pipeline between a server and application to inspect, route, or modify request and response messages for a specific purpose.

* Host – The process an application and server execute inside of, primarily responsible for application startup. Some Servers are also Hosts.

## 3\. Request Execution

Broadly speaking, a server invokes an application (providing as arguments an environment dictionary with request and response headers and bodies); an application either populates a response or indicates an error.

### 3.1. Application Delegate

The primary interface in IOPA is called the _application delegate_ or _AppFunc_. An application delegate takes the Dictionary environment and returns a Promise or a Task when it has finished processing.

    
#### Node.js AppFunc (returns a Promise/A)

    var myAppFuncPromise = function() {...};

where `this` is set to the Dictionary environment and `myAppFuncPromise` is a Promise/A promise that can be chained with     `myAppFuncPromise.then(... , ... )` etc.
    
#### .NET

    using AppFunc = Func<
        IDictionary<string, object>, // Environment
        Task>; // Done

> The application MUST eventually complete the returned _task/promise_, or throw an exception.


### 3.2. Environment

The Environment object stores information about the request, the response, and any relevant server state.  The server is responsible for providing body streams and header collections for both the request and response in the initial call. The application then populates the appropriate fields with response data, writes the response body, and returns when done.

* The environment object MUST be non-null, mutable and MUST contain the keys listed as required in the tables below (listed under **IOPA Key Name** column title)

* Keys MUST be compared using StringComparer.Ordinal.

* The values associated with the keys MUST be non-null, unless otherwise specified.

* The implementation MAY provide aliases that are convenient to access in the selected programming language chosen (i.e., ECMAScript/JavaScript, C#) to avoid `context["iopa.Key"]` type accessors in favor of `this.owinKey` (for intellitype, strong typing, capitalization conventions, separation of `request` and `response` objects, etc.).  

* If a server does not implement alias names, middleware such as [IOPA/iopa](http://github.com/iopa/iopa) MAY be used to add such alias names.  

* Alias names used by the OwinJS/owinjs reference implementation and indicated in the table below, are RECOMMENDED as the preferred naming convention.  Additional aliases or helper functions MAY be provided in addition to these.

* Where provided, alias property getters and setters MUST ensure continued synchronization with the original environment dictionary property (i.e., these are reference *mirrors* not value *copies*).  

* Periods in **IOPA Key Names** are considered part of the single string and therefore require quotes for access in most C-style languages (e.g., `var body = context["iopa.RequestBody"];`).

* Periods in **alias names** indicate separate layers in the object hierarchy (e.g., `context` object contains a `request` alias property which contains a `body` property, a `path` string, a `pathBase` string etc.).  All aliases key names SHOULD be in *camelCase* capitalization.   (e.g., `var body = this.request.body;`)

* Implementations of IOPA servers and/or middleware harnesses MAY omit the context variable as an explicit parameter for applications and middleware functions and instead set the base language's context object (e.g., `this` in ECMAScript/Javascript).

* The environment dictionary SHOULD allow additional prototype methods to be added to its prototype object, to facilitate alias implementations that are defined once per server instance, not once per request

### 3.2.1 Request Data

Required | IOPA Key Name | Recommended Aliases  | Value Description
:------: | ------------- | ---------------- | -------------------------------------
Yes | "iopa.RequestBody" | this.request.body<br>this.request | A Stream/BufferList with the request payload, if any Stream.  Null MAY be used as a placeholder if there is no request body. See [Request Body][7].
Yes | "iopa.RequestHeaders" | this.request.headers | A Dictionary of request headers/options. See [Headers][6].
Yes | "iopa.RequestMethod" | this.request.method | A `string` containing the request method of the request (e.g., `"GET"`, `"PUT"`, `"DELETE"`, `"POST"`, `"CONNECT"`, `"SUBSCRIBE"`).
Yes | "iopa.RequestPath" | this.request.path | A `string` containing the request path. The path MUST be relative to the "root" of the application delegate; see [Paths][14].
Yes | "iopa.RequestPathBase" | this.request.pathBase|  A `string` containing the portion of the request path corresponding to the "root" of the application delegate; see [Paths][14].
Yes | "iopa.RequestProtocol" | this.request.protocol | A `string` containing the protocol name and version (e.g. `"COAP/1.0"`, `"HTTP/1.1"`, or `"MQTT/3.1.1"`).
Yes | "iopa.RequestQueryString" | this.request.queryString | A `string` containing the query string component of the request URI, without the leading “?” (e.g., `"foo=bar&amp;baz=quux"`). The value may be an empty string.
Yes | "iopa.RequestScheme" | this.request.scheme | A `string` containing the URI scheme used for the request (e.g., `"http"`, `"coap"`, `"https"`, `"mqtt"`); see [URI Scheme][12].

### 3.2.2 Response Data

| Required | IOPA Key Name | Recommended Aliases  |  Value Description |
| :---: | --- | --- | ------- |
| Yes | "iopa.ResponseBody" | this.response.body<br>this.response | A Stream/BufferList used to write/append the response payload, if any. See [Response Body][22]. |
| Yes | "iopa.ResponseHeaders" | this.response.headers | A Dictionary of response headers/options. See [Headers][6]. |
| Yes | "iopa.ResponseStatusCode" | this.response.statusCode | An optional `integer` containing the REST response status code as defined by the transport protocol (COAP, HTTP or MQTT). |
| Yes | "iopa.ResponseReasonPhrase" | this.response.reasonPhrase | An optional `string` containing the reason phrase associated the given status code. If none is provided then the server SHOULD provide a default as described in [RFC 2616][23] section 6.1.1 |
| Yes | "iopa.ResponseProtocol" | this.response.protocol | An optional `string` containing the protocol name and version (e.g. `"COAP/1.0"`, `"HTTP/1.1"`, or `"MQTT/3.1.1"`). If none is provided then the “iopa.RequestProtocol” key’s value is the default. | 

### 3.2.3 Other Data

| Required | IOPA Key Name | Recommended Aliases |  Value Description |
| :---: | --- | --- | ------- |
| Yes | "iopa.CallCancelled" | this.iopa.callCancelled| A CancellationToken indicating if the request has been cancelled/aborted. See [Request Lifetime][24]. |
| Yes | "iopa.Version" | this.iopa.version | The string `"1.2"` indicating IOPA version. See [Versioning][20]. |
 
### 3.2.4 Common Keys
 
In addition to the keys above the host, server, middleware, application, etc. may add arbitrary data associated with the request or response to the environment dictionary.  Guidelines for additional keys and a list of commonly defined keys can be found in [CommonKeys][25].

### 3.3. Headers

The headers/options of the HTTP/COAP/MQTT request and response messages are represented by objects of type `IDictionary` (C#) / object `{"key" : "value"}` (ECMAScript). The requirements below are predicated on [RFC 2616 section 4.2][26].

  * The dictionary MUST be mutable.
  * Keys MUST be HTTP/COAP/MQTT field-names without `':'` or whitespace.
  * Keys MUST be compared using OrdinalIgnoreCase.
  * All characters in key and value strings SHOULD be within the ASCII codepage.
  * The value array returned is assumed to be a copy of the data. Any intended changes to the value array MUST be persisted back to the headers dictionary manually by via headers[headerName] = modifiedArray; or headers.Remove(header).
  * Header values are assumed to be in a mixed format, meaning that a normally comma separated header may appear as a single entry in the values array, one entry per value, or a mixture of the two.
  * Servers, applications, and intermediaries SHOULD NOT split or merge header values unnecessarily. While the three formats are supposed to be interchangeable, in practice many existing implementations only support one specific format. Developers should have the flexibility to support existing implementations by producing or consuming a selected format without interference.

### 3.4. Request body, 100 Continue, and Completed Semantics

If the request indicates there is an associated body the server SHOULD provide a Stream/BufferList in the `iopa.RequestBody` key to access the body data. Stream.Null MAY be used as a placeholder if there is no request body data expected. If the request Expect header indicates the client requests a 100 Continue, it is up to the server to provide iopa. The application MUST NOT set “iopa.ResponseStatusCode” to 100. 100 Continue is only an intermediate response and using it would prevent the application from providing a final response (e.g. 200 OK). 

  * The application delegate SHOULD NOT complete its returned Task and return control to the server until it is finished with the request body. Once the AppFunc Task is complete the application SHOULD NOT continue to read from the request stream.
  * The application MUST signal completion or failure of the response body by completing its returned Task or throwing an exception. After completing the Task, the application SHOULD NOT write any further data to the stream.
  * If the server signals the “iopa.CallCancelled” CancellationToken during the execution of the application delegate, the application SHOULD NOT attempt further reads from the stream, and SHOULD promptly complete the application delegate Task.
  * The application SHOULD NOT close or dispose the given stream unless it has completely consumed the request body. The stream owner (e.g. the server or middleware) MUST do any necessary cleanup once the application delegate’s Task completes.
  * Any exceptions thrown from the request body stream are fatal and SHOULD be returned to the server by being thrown synchronously from the AppFunc or by failing the asynchronous Task with the given exception(s).

### 3.5. Response Body

The server provides a response body Stream with the `iopa.ResponseBody` key in the initial environment dictionary. The headers, status code, reason phrase, etc., can be modified up until the first write to the response body stream. Upon first write, the server validates and sends the headers.Applications MAY choose to buffer response data to delay the header finalization.

  * The application MUST signal completion or failure of the body by completing its returned Task or throwing an exception. After completing the Task, the application SHOULD NOT write any further data to the stream.
  * If the server signals the `iopa.CallCancelled` CancellationToken during the execution of the application delegate, the application SHOULD NOT attempt further writes to the stream, and SHOULD promptly complete the application delegate Task.
  * The application SHOULD NOT close or dispose the given stream as middleware may append additional data. The stream owner (e.g. the server or middleware) MUST perform any necessary cleanup once the application delegate’s Task completes.

> An application SHOULD NOT assume the given stream supports multiple outstanding asynchronous writes. The application developer SHOULD verify that the server and all middleware in use support this pattern before attempting to use it.

### 3.6. Request lifetime

The full scope or lifetime of a request is limited by the several factors, including the client, server, and application delegate. In the simplest scenario a request’s lifetime ends when the application delegate has completed and the server gracefully ends the request. Failures at any level may cause the request to terminate prematurely, or may be handled internally and allow the request to continue.

The `"iopa.CallCancelled"` key is associated with a CancellationToken that the server uses to signal if the request has be aborted. This SHOULD be triggered if the request becomes faulted before the AppFunc Task is completed. It MAY be triggered at any point at the providers discretion. Middleware MAY replace this token with their own to provide added granularity or functionality, but they SHOULD chain their new token with the one originally provided to them.

## 4\. Application Startup

When the host process starts there are a number of steps it goes through to set up the application.

1. The host creates a Properties Dictionary and populates any startup data or capabilities provided by the host.

2. The host selects which server will be used and provides it with the Properties collection so it can similarly announce any capabilities.

3. The host locates the application setup code and invokes it with the Properties collection.

4. The application reads and/or sets configuration in the Properties collection, constructs the desired request processing pipeline, and returns the resulting application delegate.

5. The host invokes the server startup code with the given application delegate and the Properties dictionary. The server finishes configuring itself, starts accepting requests, and invokes the application delegate to process those requests.

The Properties dictionary may be used to read or set any configuration parameters supported by the host, server, middleware, or application.

* The startup properties dictionary MUST be non-null, mutable and MUST contain the keys listed as required in the table below.

* Keys MUST be compared using Ordinal.

* The values associated with the keys MUST be non-null, unless otherwise specified.

| Required | IOPA Key Name | Recommended Aliases | Value Description |
| :---: | --- | --- | ------- |
| Yes | "iopa.Version" | this.iopa.version | The string `"1.2"` indicating IOPA version. Added by the server in step 2 above. See [Versioning][20]. |

In addition to these keys the host, server, middleware, application, etc. may add arbitrary data associated with the application configuration to the properties dictionary. Guidelines for additional keys and a list of commonly defined keys can be found in [CommonKeys.html][25].

## 5. URI Reconstruction

Applications often require the ability to reconstruct the complete URI of a request. This process cannot be perfect since HTTP clients do not usually transmit the complete URI which they are requesting, but IOPA makes provisions for the purpose of reconstructing the approximate URI of a request.

### 5.1. URI Scheme

This information is usually not transmitted by an HTTP client and depending on network configuration it may not be possible for an IOPA server to determine a correct value. In these cases, the server may have to manually configure or compute a value.

Servers MUST provide a best-guess value for `iopa.RequestScheme`.

### 5.2. Hostname

In the context of an HTTP/1.1 request, the name of the server to which the client is making a request is usually indicated in the Host header field-value of the request, although it might be specified using an absolute Request-URI (see RFC 2616, sections [5.1.2][27], [19.6.1.1][28]).

In the context of an COAP request or MQTT request, the name of the server is usually given on startup.

A server MUST provide a value for the `"Host"` key in the request header dictionary. The format of the value MUST be "[:]". The value SHOULD be deduced by the host using the following steps:

  1. If the Request-URI of the incoming request is an absolute URI, the value of the `"Host"` key MUST be taken from the host part of the absolute URI.
  2. If the Request-URI of the incoming request is not an absolute URI, the value of the `"Host"` key MUST be taken from the Host header field-value of the incoming request.
  3. If the Host header is not present in the incoming request (as in an HTTP/1.0 request), or if its value consists entirely of linear whitespace, the server MUST provide a sensible best-guess value for the `"Host"` key.

### 5.3. Paths

Servers may have the ability to map application delegates to some base path. For example, a server might have an application delegate configured to respond to requests beginning with `"/my-app"`, in which case it should set the value of `iopa.RequestPathBase` in the environment dictionary to `"/my-app"`. If this server receives a request for `"/my-app/foo"`, the “`iopa.RequestPath` value of the environment dictionary provided to the application configured to respond at `"/my-app"` should be `"/foo"`.

  * The value associated with the environment key `iopa.RequestPathBase` MUST NOT end with a slash and MUST either start with a slash or be `""`.

  * The value associated with the environment key `iopa.RequestPath` MUST start with a slash, or MAY be `""` if the value associated with `iopa.Request.PathBase` is not string.empty.

### 5.4. URI Reconstruction Algorithm

The following algorithm can be used to approximate the complete URI of the current request:

####`C#`

    var uri =
      (string)Environment["iopa.RequestScheme"] + 
       ""://" +
       Headers["Host"].First() +
      (string)Environment["iopa.RequestPathBase"] +
      (string)Environment["iopa.RequestPath"];
        
    if (Environment["iopa.RequestQueryString"] != "")
      uri += "?" + (string)Environment["iopa.RequestQueryString"];

The result of this algorithm may not be identical to the URI the client used to make the request; for example, the server may have done some rewriting to canonicalize the request. Further, it is subject to the caveats described in the [URI Scheme][12] and [Hostname][13] sections above.

### 5.5. Percent-encoding

A URI uses percent encoding to transport characters outside its normally allowed character rules ([RFC 3986][29] section 2). Percent-encoding is used to express the underlying octets present in a URI component, whose octets are interpreted via UTF-8 encoding. Most web server implementations will perform percent-decoding on paths in order to perform request routing (as they rightly may, see: RFC 2616 section [5.1.2][27], also [3.2.3][30]), and IOPA follows this precedent. The request query string in IOPA is presented in its percent-encoded form; a percent-decoded query string could contain `'?'` or `'='` characters, which would render the string unparseable.

  * The server MUST provide percent-decoded values for `iopa.Request.Path` and `iopa.Request.PathBase`.
  * The server MUST provide a percent-encoded value for `iopa.Request.QueryString`

## 6. Error Handling

While there are standard exceptions such as ArgumentException and IOException that may be expected in normal request processing scenarios, handling only such exceptions is insufficient when building a robust server or application. If a server wishes to be robust it SHOULD consistently address all exception types thrown or returned from the application delegate or body delegate. The handling mechanism (e.g. logging, crashing and restarting, swallowing, etc.) is up to the server and host process.

### 6.1. Application Errors

An application may generate an exception in the following places:

  * Thrown from an invocation of the application delegate.
  * Provided as the result of the application delegate Task.

An application SHOULD attempt to trap its own internal errors and generate an appropriate (possibly 500-level) response rather than propagating an exception up to the server.

After an application provides a response, the server SHOULD wait to receive at least one write from the response Stream before writing the response headers to the underlying transport. In this way, if instead of a write to the Stream the server gets an exception from the application delegate Task, the server will still be able to generate a 500-level response. If the server gets a write to the Stream first, it can safely assume that the application has caught as many of its internal errors as possible; the server can begin sending the response. If an exception is subsequently received, the server MAY handle it as it sees fit (e.g. logging, write a textual description of the error to the underlying transport, and/or close the connection).

### 6.2. Server Errors

When a server encounters errors during a request’s lifetime it SHOULD signal the CancellationToken it provided in `iopa.CallCancelled`. The server MAY then take any necessary actions to terminate the request, but it SHOULD be tolerant of completion delays of the application delegate.

## 7\. Versioning

Future updates to this standard may contain breaking changes (e.g. signature changes, key additions or modifications, etc.) or non-breaking additions. While addressing specific changes is the responsibility of later versions of the standard, here are initial guidelines for expected changes:

* This standard uses Semantic Versioning as described at  (e.g. Major.Minor.Patch).

* Breaking changes to the API signatures or existing keys will require incrementing the major version number (e.g. IOPA 2.0)

* Adding new keys or delegates in a backwards compatible way only requires incrementing the minor version number (e.g. IOPA 1.1).

* Making corrections and clarifications to the document alone only requires incrementing the patch version number and last modified date (e.g. IOPA 1.0.1).

* The `"iopa.Version"` key in the startup Properties and request Environment dictionaries indicates the latest version of the standard implemented by the server and may be used to dynamically adjust behaviors of applications.  Major and Minor versions are kept consistent on IOPA as far as practical.

* All implementers SHOULD clearly document the full version number(s) of the IOPA standard they support.

* The keys listed in [CommonKeys][25] are strictly optional. Additions may be made there without directly affecting the IOPA standard or version number.

## 8\. Extensions

| Extension | Description |
| --------- | ----------- |
| [Common Keys](./CommonKeys.md)| Guidelines for exending IOPA via extension keys in the various IDictionaries.| 
| [AppBuilder](https://github.com/iopa/iopa/blob/master/README.md#middlewareapplication-pipeline-builder-appbuilder)| AppBuilder (implementation)|
| [Opaque](./Opaque.md)| IOPA Opaque Stream Extension.| 
| [WebSocket](./Websocket.md)| IOPA WebSocket Extension.| 
| [PubSub](./PubSub.md)| IOPA PubSub Extension.| 
| [nodekit](./nodekit.md)| Extensions to support the nodekit.io project| 

## 9\. Real World Usage

| Extension | Description |
| --------- | ----------- |
| [AppBuilder](https://github.com/iopa-docs/iopa-spec/blob/master/README.md)| Real word usage of AppBuilder Pipeline|



   [1]: #Overview
   [2]: #2-definitions
   [3]: #3-request-execution
   [4]: #31-application-delegate
   [5]: #32-environment
   [6]: #33-headers
   [7]: #34-request-body-100-continue-and-completed-semantics
   [8]: #35-response-body
   [9]: #36-request-lifetime
   [10]: #4-application-startup
   [11]: #5-uri-reconstruction
   [12]: #51-uri-scheme
   [13]: #52-hostname
   [14]: #53-paths
   [15]: #54-uri-reconstruction-algorithm
   [16]: #55-percent-encoding
   [17]: #6-error-handling
   [18]: #61-application-errors
   [19]: #62-server-errors
   [20]: #7-versioning
   [201]: #8-extensions
   [202]: #9-real-world-usage
   [21]: http://www.ietf.org/rfc/rfc2119.txt
   [22]: #35-response-body
   [23]: http://www.ietf.org/rfc/rfc2616.txt
   [24]: #5-uri-reconstruction
   [25]: ./CommonKeys.md
   [26]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
   [27]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.1.2
   [28]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html#sec19.6.1.1
   [29]: http://www.ietf.org/rfc/rfc3986.txt
   [30]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.2.3
