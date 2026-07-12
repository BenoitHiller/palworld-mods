# Better Wings

This mod rebalances the stats of the Wing Pack so it feels better to use.

The changes I made are that:

* All speed limits have been substantially increased.
* Acceleration when moving downwards has been substantially increased
* Deceleration when moving upwards has been slightly decreased
* You can fly downwards at a steeper angle
* You don't stall as easily flying upwards
* Fuel consumption has been reduced by 50%

**Heads up these changes are only about as balanced as pre-1.0 Jetragon.**

This results in something that feels a lot more like a typical game glider, where you get a satisfying burst of speed when you angle downwards and can use this to extend your range by dolphin diving.

This is very much a bandaid over the problem though. The physics they implemented need some much more substantial tweaks to make things feel really good.

If I increase the speed further it feels a bit better, but then it becomes too easy to hit the effective "speed limit" of the game. There is a point where instead of things popping late in the whole game hangs so that loading can catch up.

## Installation

The recommended method is to install the mod by subscribing on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3763559317).

After you subscribe to the mod, do these steps to enable the mod:

1. Launch the game and wait until you get to the title screen.
2. Go to Options > Mod Management and make sure **Enable Mod** is set to **ON**.
3. Make sure the checkboxes next to Better Wings, UE4SS Experimental (Palworld), and PalSchema are **CHECKED**
4. Click the blue **Save** button and the game will now restart.
5. Once the game starts up again, Better Wings should now be enabled.

## Building

To build the mod use the following command in the root of the repository:

```bash
make BetterWings
```

This will generate both a folder `./out/workshop/3627071990` which contains the steam workshop files. As this mod is just using PalSchema the make step is just copying some of the files into a different folder.

You can use the following command to install the generated files into your local Steam Workshop folder so that the game will find them:

```bash
make install MODS=BetterWings
```
