# [![IOPA](http://iopa.io/iopa.png)](http://iopa.io)<br> iopa-router 

[![Build Status](https://api.shippable.com/projects/56e2594e9d043da07bb7cc63/badge?branchName=master)](https://app.shippable.com/projects/56e2594e9d043da07bb7cc63) [![IOPA](https://img.shields.io/badge/iopa-middleware-c24f8c.svg?style=flat-square)](http://iopa.io)

[![NPM](https://nodei.co/npm/iopa-router.png?downloads=true)](https://nodei.co/npm/iopa-router/)

## About
`iopa-router` is lightweight router for the IOPA framework

It routes HTTP, COAP and MQTT requests, with simple uri templates and parameter/query string parsing.  

## Usage

### Installation:

    npm install iopa-router
    
### Hello World 
    
``` js
const Router = require('iopa-router'),
    iopa = require('iopa'),
    http = require('http'),
    iopaConnect = require('iopa-connect')

var app = new iopa.App();

app.use(Router);

app.get('/hello', function(context, done){
          context.response["iopa.Body"].end("<HTML><HEAD></HEAD><BODY>Hello World</BODY>");
          return done();
          });
          
 app.get('/goodbye', function(context, done){
          context.response["iopa.Body"].end("<HTML><HEAD></HEAD><BODY>Goodbye World</BODY>");
          return done();
          });

http.createServer(app.buildHttp()).listen(3000);
``` 

## Methods

* `route.get`:  Match `GET` requests
* `route.post`: Match `POST` requests
* `route.put`:  Match `PUT` requests
* `route.head`: Match `HEAD` requests 
* `route.del`:  Match `DELETE` requests
* `route.options`:  Match `OPTIONS` requests
* `route.all`:  Match all above request methods.
* `route.debugget`:  Match `GET` for `scheme='debug'` requests
	
## API


If you want to grab a part of the path you can use capture groups in the pattern:

``` js
route.get('/id/{customer}', function() {
	var base = this.Params.base; // ex: if the path is /id/bar, then customer = bar
```

Query paramaters in the url are also added to `owin.Params`:

``` js
route.get('/id/{customer}', function() {
	var base = this.Params.base; // ex: if the path is /id/bar?name=dog, then customer = bar
	var name = this.Params.name; // ex: if the path is /id/bar?name=dog, then name = dog
});
```

The capture patterns matches until the next `/` or character present after the group

``` js
route.get('/{x}x{y}', function() {
	// if the path was /200x200, then his.Params = {x:'200', y:'200'}
});
```

Optional patterns are supported by adding a `?` at the end

``` js
route.get('/{prefix}?/{top}', function() {
	// matches both '/a/b' and '/b'
});
```

If you want to just match everything you can use a wildcard `*` which works like posix wildcards

``` js
route.get('/{prefix}/*', function() {
	// matches both '/a/', '/a/b', 'a/b/c' and so on.
	// the value of the wildcard is available through req.params.wildcard
});
```

If the standard capture groups aren't expressive enough for you can specify an optional inline regex 

``` js
route.get('/{digits}([0-9]+)', function() {
	// matches both '/24' and '/424' but not '/abefest' and so on.
});
```

You can also use regular expressions and the related capture groups instead:

``` js
route.get(/^\/foo\/(\w+)/, function(req, res) {
	var group = req.params[1]; // if path is /foo/bar, then group is bar
});
```

## Error handling

By default iopa-router will simply move to next iopa middleware function if no route matched.    
The router is a Promise/A compatible async function that respects error bubbling, but has no specific handling built in.

You can provide a catch-all to a given route that is called if no route was matched:

    route.get(function(context) {
	// called if no other get route matched
	context.response.writeHead(404);
	context.response.end('no GET handler found');
    });

## Credits

This router was ported from [gett/router](https://github.com/gett/router) which was developed under MIT license by Mathias Buus Madsen and Ian Jorgensen.

It has been developed to be a core component of the IOPA ecosystem.