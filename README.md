[![IOPA](http://iopa.io/iopa.png)](http://iopa.io)

## This Repository

This is the official repository of the IOPA (Internet of Protocols Alliance) Specification and is the 
source of all the documentation at [iopa.io](http://iopa.io).

## About

IOPA defines a platform-independent, protocol-independent standard framework for the Internet of Things (IOT).  

## Specification
[IOPA Specification](./docs/Specification.md)  (this repository)

We recommend reviewing the reference implementation, [iopa-io/iopa](http://github.com/iopa-io/iopa), in conjunction with this IOPA specification, so that you get a sense for the implementation possibilities.

## To Re-Build the Documentation

This repository uses [hexo](http://hexo.io) to generate the documentation

Install dependencies:

``` bash
$ git clone https://github.com/iopa-io/iopa-docs.git
$ cd iopa-docs
$ brew install homebrew/science/vips --with-webp --with-graphicsmagick
$ npm install
```

Generate:

``` bash
$ npm run clean
$ npm run build
```

Run server:

``` bash
$ hexo server
```

## License

[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
Documentation under CC BY-SA 4.0 Copyright (c) 2016 Internet of Protocols Association
Documentation theme Copyright (c) 2013 Tommy Chen, Hexo Contributors (CC BY 4.0)