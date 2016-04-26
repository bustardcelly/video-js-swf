# About
> Information for properly working on forked [video-js-swf](https://github.com/videojs/video-js-swf) project as a 3rd party.

## Local Repository Setup
The following steps will setup your local repository to work on local `origin` and commit to remote `origin` - which is this forked repository.

1. Clone this forked repo
2. `cd` into the clones repo
3. Define the original repository as `upstream`
4. Check out the `origin` branch of *red5pro* locally

$ git clone git@github.com:red5pro/video-js-swf.git
$ cd video-js-swf
$ git remote add updstream git@github.com:videojs/video-js-swf.git
$ git checkout -b feature/red5pro origin/feature/red5pro

The first `clone` will automatically pull down a checkout of the *master* branch on `origin` (which is inline with the `upstream` master). The *red5pro* feature branch is based on the work from the original *master* of the forked repo.

To keep this fork inline and rebase-able with the [video-js-swf](https://github.com/videojs/video-js-swf) project, we can then go about developing in our forked `origin` and fetch updates on `upstream` to be merged in.

## Pulling in Updates from video-js-swf Releases
In order to pull in any feature updates and fixes from the [video-js-swf](https://github.com/videojs/video-js-swf), keep the setup `upstream` inline with the original project repository:

```
$ git checkout master
$ git fetch upstream
$ git rebase upstream/master
$ git checkout red5pro
$ git rebase master
$ git push origin -u HEAD
```

This, essentially, pulls down any updates on `upstream/master` into `origin/master` (our local/remote fork) then attempts to rebase/merge the changes into our work on *red5pro*.

_You may want to try a `merge` instead of rebase, depending on the progression of this fork._
