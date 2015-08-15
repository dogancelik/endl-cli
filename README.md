# endl-cli
Download setup files from Internet and install them easily with *endl-cli*.

*endl-cli* uses [*endl*](https://github.com/dogancelik/endl) as backend.

## Install
[![NPM](https://nodei.co/npm/endl-cli.png?mini=true)](https://nodei.co/npm/endl-cli/)

Prerequisites: Tools for building NodeJS native modules (Visual Studio)

Visual Studio has a free version at  [www.visualstudio.com](https://www.visualstudio.com/en-us/products/visual-studio-express-vs.aspx).

## Examples

### Simple example

Downloads mp3tag.

```sh
endl d "http://www.mp3tag.de/en/download.html" "div.download a"
```

### [More examples](https://github.com/dogancelik/endl-cli/wiki/Examples)

## To-Do

* Modularize CLI
* Add tests
* Use CLI as a package manager (maybe)
