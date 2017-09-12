# revolution ☸️

A build system using [`fpm-cookery`][fpm-cookery] for Travis CI.

## Building

To setup a build environment, first boot the Vagrant VM:

```
$ vagrant up
```

Once finished, shell into the VM:

```
$ vagrant ssh
```

Inside the Vagrant machine, install ruby gem dependencies:

```
$ gem install bundler
$ bundle install
```

## License

Licensed under either of
* Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
* MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
  at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.

 [fpm-cookery]: https://github.com/grindrlabs/fpm-cookery
