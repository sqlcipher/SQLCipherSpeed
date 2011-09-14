# SQLCipherSpeed

A project for testing the speed of [SQLCipher](http://github.com/sjlombardo/sqlcipher) on an iOS device, and measuring the impact of the encryption used compared to [SQLite](http://www.sqlite.org).

This fork of the project is a bit of a build-out for the main fork, it stores and displays previous test runs and provides a display averaging those results together. 

## iOS 4 Only

**Please Note:** This fork of SQLCipherSpeed requires iOS 4 because it makes use of blocks and Grand Central Dispatch to run the tests without blocking the main run loop. It is not currently compatible with iOS 3 (but if you want to try patching that in, feel free to fork, hack it out, and send us a pull request.)

## Prerequisites for Building

Before you build this project, you'll need to load up the submodules used, e.g.:

    $ git clone git://github.com/billymeltdown/SQLCipherSpeed.git
    $ cd SQLCipherSpeed
    $ git submodule init
    $ git submodule update
    
You'll also need to create a recursive source tree in your XCode Preferences named `OPENSSL_SRC` that points to a checkout of the latest OpenSSL source on your workstation. *Check http://openssl.org/source/ for the latest version, below is just an example.*

    $ curl -C - -O http://openssl.org/source/openssl-1.0.0e.tar.gz
    $ tar xf openssl-1.0.0e.tar.gz
    $ cd openssl-1.0.0e
    $ pwd

Setting up the source tree:

1. Copy the output of the `pwd` command above to your clipboard, make sure you get the whole path
2. In Xcode, navigate to Preferences -> Source Trees
3. Use the + button to create a new one, name it OPENSSL_SRC, and paste the path to OpenSSL from your clipboard

## Cipher Page Size

There's a textfield on the main screen for running the tests, labeled "Page Size." Currently it doesn't do anything on the latest stable version of SQLCipher, but it does get used by the next version currently in development, [SQLCipher branch v2beta](https://github.com/sjlombardo/sqlcipher/tree/v2beta), which allows the user to do something like `PRAGMA cipher_page_size=1024` to set a custom page size.

## Need help? Want to help?

Pull requests are encouraged, feature requests are up to you! Feel free to say, "hello", on [the SQLCipher discussion list](http://groups.google.com/group/sqlcipher).

### Legal

This project is owned and maintained by [Zetetic](http://zetetic.net). It is provided under an MIT-style open-source license (see LICENSE.txt).
