# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
* CHANGELOG.md file
* alarm user is now member of sudo group
* Retrieve staging packages during build process
* Make targets to install dependencies and PirateBox via chroot
* Testing checklist
* Support for RPi 2
* Support for RPi Zero

### Changed
* No need to start qemu manually - everything is now done via chroot
* Automated installation of dependencies
* Automated installation of PirateBox
* root user is not allowed to log in via ssh
* README converted to MarkDown

### Imporved
* initial package selection
* only install/update new packages, do not reinstall packages that are available
* qemu start scripts
