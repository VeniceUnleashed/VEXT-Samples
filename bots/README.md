# Bots

This mod implements and demonstrates a very simple bot manager that can be used in your mods to spawn and manage bots.

## Usage

To try the mod simply load it on your server, connect, and use one of the available console commands (`bots.spawn`, `bots.kick`, and `bots.kickAll`) to spawn / kick bots. Here's an example of spawning a bot called `BotMan`, in team `US` with no squad, on the right balcony of Ziba tower:

```
bots.spawn BotMan Team1 SquadNone 10.583669 10.885241 37.143791
```

## API

If you want to use this in your mods simply copy the `bots.lua` script to your mod and require it from your own scripts. The script returns an object that has the following methods:

| Method | Description |
| ------ | ----------- |
| `Player createBot(string name, TeamId team, SquadId squad)` | Creates a bot with the specified name and puts it in the specified team and squad. |
| `bool isBot(player)` | Returns `true` if the specified player is a bot, `false` otherwise. |
| `SoldierEntity spawnBot(Player bot, LinearTransform transform, CharacterPoseType pose, DataContainer soldierBlueprint, DataContainer soldierKit, DataContainer[] unlocks)` | Spawns a bot at the provided `transform`, with the provided `pose`, using the provided soldier blueprint, kit, and unlocks. |
| `void destroyBot(Player bot)` | Destroys / kicks the specified `bot` player. |
| `void destroyAllBots()` | Destroys / kicks all bot players. |

This script also exposes a new event that can be used to modify the behavior of bots (usually by changing their input state): `Bot:Update(Player bot, float deltaTime)`

Keep in mind that requiring the class from multiple scripts will still return the same instance. Also keep in mind that bots get automatically kicked when the mod gets reloaded.

For examples on how to use this API refer to the [server init script](/bots/ext/Server/__init__.lua) of this mod.
