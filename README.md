# Cocoapods release

CocoaPods release is a little helper that let's you release pods more easily.

## Installation

    $ gem install cocoapods-release

## Usage

1. Change the version in your `podspec` file.
2. Run `pod release`.

`pod release`
* tags and pushes your current branch
* automatically finds the repository hosting your existing podspec (master or private, doesn't matter) and
* pushes to podspec for you.

## Author

Oliver Letterer

- http://github.com/OliverLetterer
- http://twitter.com/oletterer
- oliver.letterer@gmail.com
