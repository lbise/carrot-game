# Carrot Game

A rabbit collects carrots in a forest. Made for two players aged 4 and 6: no way to lose, lots of feedback.

Godot 4.7 (Jolt physics). Models are imported directly from `.blend` files (Blender 5.2).

## Run

Open the folder in Godot and press **F5**. The main scene is `levels/test_level.tscn`.

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | WASD or arrow keys | Left stick or D-pad |
| Jump | Space | A (bottom face button) |
| Restart level | R | Start |

## Layout

| Path | What |
|---|---|
| `levels/level.gd` | Put this on the root of any level. It finds every carrot (group `carrot`), updates the HUD and celebrates when all are found. The level needs nodes named `Rabbit`, `HUD` and `WinJingle`. |
| `levels/test_level.tscn` | Sandbox: ground, a platform, 6 carrots |
| `rabbit/rabbit.tscn` + `.gd` | The player. Placeholder model made of spheres under `Model`. The state machine is IDLE / MOVE / AIR / LAND / CELEBRATE. The "animation" is squash and stretch on `Model`. |
| `carrot/carrot.tscn` + `.gd` | The collectible. The model is `models/carrot.blend`. Drop instances anywhere. |
| `camera/follow_camera.gd` | Fixed-angle follow camera. Place it in the editor: the offset to the target at start is kept. |
| `ui/hud.tscn` + `.gd` | The counter and the "Bravo !" message (`win_text` export) |
| `models/*.blend` | Imported directly. Import settings: Visible Only, no cameras, no punctual lights |
| `sounds/kenney/` | Four CC0 Kenney audio packs (impact, interface, jingles, digital) to audition and swap in |

## Tweak without code (Inspector exports)

- **Rabbit:** speed, jump velocity, hop height and rate, squash and stretch amounts, land thud threshold, fall limit
- **Carrot:** spin speed, bob height and speed
- **Camera:** smoothing
- **HUD:** win text

## Sounds in use

| Sound | Node | File |
|---|---|---|
| Jump | Rabbit/JumpSound | `digital-audio/phaseJump1.ogg` |
| Landing | Rabbit/LandSound | `impact-sounds/footstep_grass_000.ogg` |
| Carrot pickup | Carrot/PickupSound | `interface-sounds/pluck_002.ogg` |
| Win | TestLevel/WinJingle | `music-jingles/Pizzicato jingles/jingles_PIZZI00.ogg` |

These were picked by name, without listening. Audition the packs in the FileSystem dock and swap the `stream` on each node.

## Licences

Sounds: Kenney (CC0, see each pack's `License.txt`). Models: our own.
