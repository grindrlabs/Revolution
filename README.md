# revolution ☸️ [![Build Status](https://travis-ci.org/grindrlabs/revolution.svg?branch=master)](https://travis-ci.org/grindrlabs/revolution)

A build system using [`fpm-cookery`][fpm-cookery] for Travis CI.

* [Using Revolution](#using-revolution)
    * [Installing the gem](#installing-the-gem)
    * [Directory structure](#directory-structure)
    * [CLI Commands](#cli-commands)
        * [order: output build order](#order-output-build-order)
        * [build](#build)
        * [clean](#clean)
        * [sign](#sign)
        * [deploy](#deploy)
* [Developing Revolution](#developing-revolution)
    * [Development Environment](#development-environment)
    * [Submitting changes](#submitting-changes)
* [License](#license)
    *  [Contribution](#contribution)

## Using Revolution

### Installing the gem

Add the Revolution gem to your Gemfile to [have Bundler install it from GitHub](http://bundler.io/v1.16/guides/git.html).

**Gemfile**

```ruby
gem 'revolution', git: 'https://github.com/grindrlabs/revolution.git',
                  branch: 'master',
                  ref: '{commit hash}'
```

**Note: Revolution is still in development.** Be sure to specify the `ref` above with the latest from our [commit history](https://github.com/grindrlabs/revolution/commits/master).

Then run `$ bundle install --system`

### Directory structure

Revolution expects there to be a recipe root directory containing a subdirectory for each package. Within the package subdirectory is an [fpm-cookery recipe.rb file](https://fpm-cookery.readthedocs.io/en/latest/pages/getting-started/#the-recipe).

```
.
├── recipes/
│   ├── my-recipe/
│   │   ├──
│   │   ├── recipe.rb
│   │   └── scripts/
│   │       └── post-install
.
.
.
```

### CLI Commands

#### `order`: output build order

The `order` command only outputs what the build order will be if you run `build --all`. No files are changed.

```
$ bundle exec revolution order --recipe-root recipes
```

#### `build`

Building a single package:
```
$ bundle exec revolution build {package_name} --recipe-root recipes
```

Building all the packages in your recipe root:
```
$ bundle exec revolution build --all --recipe-root recipes
```

#### `clean`

Remove a single rpm and its cache:
```
$ bundle exec revolution clean {package_name} --recipe-root recipes
```

Remove all built packages within the recipe root:
```
$ bundle exec revolution clean --all --recipe-root recipes
```

#### `sign`

Signing a single package:
```
$ bundle exec revolution sign {package_name} --recipe-root recipes
```

Sign all the packages in your recipe root:
```
$ bundle exec revolution sign --all --recipe-root recipes
```

#### `deploy`

Deploy should only be called after signing. Revolution will throw an exception if it finds unsigned packages at this stage.
```
$ bundle exec revolution deploy --recipe-root recipes --config config.yml
```

Your config file should have the following contents:

**config.yml**

```yaml
---
service: aws-s3
bucket: {bucket name}
region: us-east-1
```

Currently supported services are limited to **AWS S3**.

## Developing Revolution

### Development Environment

To setup your environment, first boot the Vagrant VM:

```
$ vagrant up
```

Once finished, shell into the VM:

```
$ vagrant ssh
```

Then run the Rakefile inside the bundled environment:

```
$ bundle exec rake
```

Rake will run the RSpec test suite, which may take a few minutes.

### Submitting changes

Travis expects Revolution to pass [RuboCop](https://github.com/bbatsov/rubocop) standards, so be sure to run it before opening a PR.

----

## License

Licensed under either of
* Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
* MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
  at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.

 [fpm-cookery]: https://github.com/grindrlabs/fpm-cookery
