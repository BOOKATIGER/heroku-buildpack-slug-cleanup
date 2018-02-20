# heroku-buildpack-cleanup

Remove files that are specified in a .slugcleanup file.

## Usage

    $ heroku buildpacks:add https://github.com/Thien42/heroku-buildpack-cleanup-folder.git

    $ cat .slugcleanup
    gradle*
    node_modules

## License

MIT

### Original inspiration from
https://github.com/syginc/heroku-buildpack-cleanup.git