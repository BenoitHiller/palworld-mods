This is a collection of a few small mods I made for Palworld.

## Contents

See the linked subfolders for more details about each mod.

* [UltrakillWingRemover](./UltrakillWingRemover) Removes the wings from the ULTRAKILL collaboration models to make it easier to see.
* [LongRangeFishing](./LongRangeFishing) Extends the range at which you can fish.
* [SmallTerraprisma](./SmallTerraprisma) Shrinks the blades spawned by the Terraprisma sword so that they don't block your view.
* [SimpleReticle](./SimpleReticle) Replaces the sci-fi style default reticle with a simple cross.

As I built up a collection of them copying things around got to be very frustrating copying files around so I centralized them and set up some tooling to work around the somewhat convoluted progress of developing these mods.

**Warning to anyone trying to build anything based on this project.** This project is set up assuming that you check it out into a folder accessible by windows, but then run all commands from wsl.

This setup is less than ideal given how it bounces back and forth between windows and linux, but I work most quickly in a linux environment and I'm working on mods for a game I'm running on windows.

## Building

The build process has a few dependencies:

* rsync
* jq
* make
* Unreal Engine 5.1.1
* powershell

It also relies on wsl having interop on and able to find `powershell.exe` in the PATH.

With that set up you can use the following command to build the associated Unreal Engine projects, and to package up all mods for both NexusMods and Steam Workshop in the `./out` folder.

```bash
make
```

This takes at least a minute for me, even on unchanged rebuild, due to building the unreal projects. As such you can request that it skips running the unreal build tool and instead just use the last Pak files. This is done by setting the `SKIP_UNREAL` variable in the environment e.g.

```bash
make SKIP_UNREAL=true
```

There are also make targets for each of the individual mods corresponding to the name of their sub-folder should you with to only build some of them.

### Build Outputs

* `./out/workshop` contains folders that can be copied into `steamapps/workshop/content/1623730` for use by the built-in Steam Workshop based mod loader.
* `./out/nexus` contains zip archives that can be uploaded to NexusMods.

### Cleaning

You can use the standard command to clean up the build and output directories.

```bash
make clean
```

This doesn't clean the Unreal build artifacts because it doesn't seem like that is even implemented for the type of project I'm using?

## Installing

There is a command to copy all the mods from `./out/workshop` into their respective folders in your steam directory.

```bash
make install
```

**Note that this will delete files that you remove from mods so be careful.** It however won't touch any mod folders which don't currently have a folder in `./out/workshop`. It also does not run the build first unless you request it.

You are also able to specify which mods should be installed by setting the `MODS` environment variable e.g.

```bash
# Install just SmallTerraprisma and UltrakillWingRemover
make install MODS="SmallTerraprisma UltrakillWingRemover"
```

## License

Everything that I've written for this project is provided to you licensed under using CC-BY-4.0 (see [LICENSE](./LICENSE) for the full text). This project contains mods for Palworld so makes indirect use of Pocketpair IP as well as direct use of a small number of game assets in accordance with their [Guidelines for Derivative Works](https://www.pocketpair.jp/guidelines-derivativework).
