# heroku-buildpack-slug-cleanup [![Build Status](https://travis-ci.org/BOOKATIGER/heroku-buildpack-slug-cleanup.svg?branch=master)](https://travis-ci.org/BOOKATIGER/heroku-buildpack-slug-cleanup)

Remove files that are specified in a .slugcleanup file.

## Usage

```bash
$ heroku buildpacks:add https://github.com/BOOKATIGER/heroku-buildpack-slug-cleanup
$ heroku config:set NODE_APP="my_app"
```

This buildpack will look for `.slugcleanup` in the root folder and in the folder pointed by the `NODE_APP` environment variable (if provided)

The purpose is to reduce Your slugsize in case you have multiple projects in your repository by keeping only the files you need in your build.

## Tests

You can run tests for this repository by using docker or docker-compose:
```bash
# docker-compose
$ docker-compose up
# docker
$ docker build -t bookatiger/heroku-buildpack-slug-cleanup .
$ docker run bookatiger/heroku-buildpack-slug-cleanup
```

Or by using heroku directly by following the instructions [here](https://github.com/heroku/heroku-buildpack-testrunner#running-buildpack-tests-on-heroku)

## License

MIT

### Original inspiration from
https://github.com/syginc/heroku-buildpack-cleanup.git
