# Litecoin wallet docker image

* Compiled from source
* Uses alpine as base
* Works with read-only filesystem (as long as you have a volume for data on `/litecoin`)
* Put the config file in `/etc/litecoin/litecoin.conf`
* Compiled with [ZeroMQ](http://zeromq.org/) support

Try it with

```
docker run --read-only -v $(pwd)/data:/litecoin -v $(pwd)/litecoin.conf:/etc/litecoin/litecoin.conf:ro lsmoura/litecoin
```

## Author

- [Sergio Moura](http://sergio.moura.ca)

