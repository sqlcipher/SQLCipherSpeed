# SQLCipherSpeed

A project for testing the speed of [SQLCipher](http://github.com/sjlombardo/sqlcipher) on an iOS device, and measuring the impact of the encryption used compared to [SQLite](http://www.sqlite.org).

This fork of the project is a bit of a build-out for the main fork, it stores and displays previous test runs and provides a display averaging those results together. 

## iOS 4 Only

**Please Note:** This fork of SQLCipherSpeed requires iOS 4 because it makes use of blocks and Grand Central Dispatch to run the tests without blocking the main run loop. It does not run on iOS 3. 

## Building

Before you go building this project in XCode, you'll need to load up the submodules used, e.g.:

    $ git submodule init
    $ git submodule update
    
You'll also need to create a recursive source tree in your XCode Preferences named OPENSSL_SRC that points to a checkout of the latest OpenSSL source on your workstation. 

## Cipher Page Size

There's a textfield on the main screen for running the tests, labeled "Page Size." Currently it doesn't do anything on the latest stable version of SQLCipher, but it does get used by the next version currently in development, SQLCipher branch v2beta, which allows the user to do something like `PRAGMA cipher_page_size=1024` to set a custom page size.

## Need help? Want to help?

Pull requests are encouraged, feature requests are up to you! Feel free to say, "hello", on [the SQLCipher discussion list](http://groups.google.com/group/sqlcipher).

### Legal

This project is owned and maintained by [Zetetic](http://zetetic.net). It is provided under an MIT-style open-source license (see LICENSE.txt).
