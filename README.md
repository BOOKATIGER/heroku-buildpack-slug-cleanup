# heroku-buildpack-cleanup-folder

Remove files that are specified in a .slugcleanup file.

## Usage

    $ heroku buildpacks:add https://github.com/Thien42/heroku-buildpack-cleanup-folder.git
    $ heroku config:set NODE_APP="my_app"


This buildpack will look for `.slugcleanup` in the root folder and in the folder pointed by the `NODE_APP` environment variable (if provided)

The purpose is to reduce Your slugsize in case you have multiple projects in your repository by keeping only the files you need in your build.

## License

MIT

### Original inspiration from
https://github.com/syginc/heroku-buildpack-cleanup.git