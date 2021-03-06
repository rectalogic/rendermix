# Overview

RenderMix is a JRuby application that mixes audio, video and images,
along with visual effects, together into a single video.

It uses [jMonkeyEngine 3](http://jmonkeyengine.org/) as a framework
for visual effects.

RenderMix requires [librawmedia](https://github.com/rectalogic/librawmedia)

## WIP

RenderMix is currently a work in progress and incomplete.
Currently testing with jme3 SVN r9857 using JRuby 1.7.0.RC1.

## Building

 * Install the librawmedia gem.
 * Build or download jMonkeyEngine, copy or symlink this into the rendermix
   directory as `jme3`, so you should have `rendermix/jme3/jMonkeyEngine3.jar`
 * bundle install other gem dependencies.

You can get sample media used in the test fixtures from
[rendermix-sample-media](https://github.com/rectalogic/rendermix-sample-media)

Test your installation by running:

    bin/rendermix --mediaroot ../rendermix-sample-media/media spec/fixtures/manifests/cinematic.json

## License

Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
Use of this source code is governed by a BSD-style license that can be
found in the LICENSE file.
