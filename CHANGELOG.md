# Changelog

## [2.2.0] - 2023-07-11

### Fixed

- Multiqc now correctly picks up all of the salmon qc files

### Changed

- Adjusted cpu and memory requirements for tasks based on actual usage


** [2.1.0] - 2023-05-23

*** Fixed

- Output files are saved where they should be (i.e. run on a bucket, save to the bucket)

*** Added

- Started skeleton to allow for different aligners
- Print log info at beginning to display some important fully resolved parameters

*** changed

- On Google Batch, use spot instances by default


## [2.0.0] - 2023-05-22

- Complete overhaul.  Now uses DSL2 and nf-core modules.
- No more conda, now just containers.
- Google Batch is working

## [1.1.1] - 2022-04-04

### Changed

- Explicitly set the minimum amount of RAM for use with BBduk

## [1.1.0] - 2022-04-04

### Changed

- Updated the version of BBMap in the container, switched to basing off of 
    Ubuntu:20.04 instead of Alpine:3.9
- Increase amount of RAM requested by BBduk


## [1.0.2] - 2021-03-04

### Changed
- Publish all files produced by Salmon
- Allow Salmon to fail to align some files without killing the pipeline
- Return to using Docker containers written for this pipeline

## [1.0.1] - 2021-03-04
### Added
- CHANGELOG.md

### Changed
- Updated README.md to include "Usage" section


[2.1.0]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/2.0.0...2.1.0
[2.0.0]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/1.1.1...2.0.0
[1.1.1]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/1.1.0...1.1.1
[1.1.0]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/1.0.2...1.1.0
[1.0.2]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/1.0.1...1.0.2
[1.0.1]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/1.0.1
