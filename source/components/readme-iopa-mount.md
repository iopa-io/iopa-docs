# [![IOPA](http://iopa.io/iopa.png)](http://iopa.io)<br> iopa-mount

[![Build Status](https://api.shippable.com/projects/55f871f91895ca447415931e/badge?branchName=master)](https://app.shippable.com/projects/55f871f91895ca447415931e) [![NPM](https://img.shields.io/badge/iopa-middleware-c24f8c.svg?style=flat-square)](http://iopa.io/)

[![NPM](https://nodei.co/npm/iopa-mount.png?downloads=true)](https://nodei.co/npm/iopa/)

## About

Mount other IOPA applications or middleware to a given pathname

## Usage

```js
npm install iopa-mount --save
```

```js
app.mount(path, function(context){});
```

### Example

```js
const iopa = require('iopa'),
  iopaMount = require('./index'),
  IOPA = iopa.constants.IOPA
 
var app = new iopa.App();

app.mount("/test", function (context, next) {
  context.log.info("HELLO WORLD");
   return Promise.resolve(null);
});

var demo = app.build();

var context = new iopa.Factory().createRequest("http://localhost/test/hello", "GET");
demo(context);

iopaFactory.dispose(context);
```