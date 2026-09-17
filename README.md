# Signal

A podcast guide for Roku: a grid of shows you move through with the remote,
a detail screen for each show, a Saved list and a search screen that uses
the Roku on-screen keyboard. No account, no server, no network, no audio
playback — the thirteen shows are bundled and the Saved list lives in the
Roku registry.

**This is a deliberately small sample channel.** It exists to show a
complete, working VibeView setup for a Roku project: the packaging command
in `vibeview.json`, the live reload loop (`vibeview dev --platform roku`,
`r` to reload or `--watch` to reload on save), and device verification by a
coding agent driving focus with the remote and typing into the on-screen
keyboard. Read how it was built and verified, with every command and its
output, at https://vibeview.io/guides/ai-agent-built-roku-channel/. Copy `vibeview.json` into your own
channel project; do not expect much from the channel itself.

Signal was written, iterated on and verified on a real, physical Roku by a
coding agent using only the [VibeView](https://vibeview.io) CLI for
everything that touched a device. There was no Roku on the agent's desk and
no Roku SDK: every reload and every remote press ran on a VibeView cloud
Roku, and the agent read the result back through VibeView's UI tree and
screenshots.

## The channel

- **Home** — a "Signal" heading, a Search button, two rows of tiles ("New
  this week" and "Talk") and a `Saved: N shows` line. Focus starts on the
  first tile of the first row. Left/right move within a row (the row slides
  when a tile would fall off the screen); down/up move between rows and
  land on the tile last focused in that row; up from the first row reaches
  Search. OK opens Detail.
- **Detail** — the tile large on the left; title, category and episode
  count, a three-sentence description and two buttons on the right: `Play`
  (focused on arrival; shows a "Now playing" line for five seconds, no
  audio) and `Save` / `Saved` (toggles; green while saved). Back returns to
  Home with focus on the tile that was opened.
- **Search** — a `MiniKeyboard` with its text box, and a grid of the shows
  whose titles contain the typed text, updated on every keystroke. The
  keyboard has focus on arrival; right (off the keyboard's edge) or down
  (off its bottom row) moves into the results, left from the first column
  returns to the keyboard. OK on a result opens Detail; Back returns to Home
  with focus on the Search button.

Focus is SceneGraph's own focus. Tiles (`ShowTile`) and buttons
(`SigButton`) are small focusable components that hold real focus via
`setFocus` and react to `focusedChild`; the three views only decide which
node receives focus for each remote press in `onKeyEvent`. Nothing draws a
highlight of its own, so the focus the device's UI tree reports is exactly
the focus on screen.

Palette: background `#101318`, card `#1C2028`, ink `#F1EFE8`, secondary ink
`#9AA0AC`, accent `#F2A33A`, saved `#3AA981`. Dark only.

Layout: plain BrightScript and SceneGraph, no framework, no build step
beyond zipping.

```
manifest                 title, version, icons, splash screens, ui_resolutions=fhd
source/main.brs          entry point
components/              SignalScene (navigation + registry), HomeView, DetailView,
                         SearchView, ShowTile, SigButton, SavedStore.brs
data/shows.json          the thirteen shows
images/                  icons, splash screens, images/shows/<id>.png tiles
scripts/make-images.py   regenerates every image with Pillow
```

Every image is generated: `python3 scripts/make-images.py` writes the Roku
icons and splash screens at the sizes the manifest specification lists and
one flat 640×360 card per show. Titles and colours come from
`data/shows.json`.

## Running it on a Roku

You need the `vibeview` CLI installed and logged in (`npm i -g vibeview`,
`vibeview login`).

```bash
vibeview build --platform roku        # package out/signal.zip and upload it (first time)
vibeview dev --platform roku          # start a live Roku session in your browser
```

While `vibeview dev` runs, press `r` to re-package, upload and reload the
channel in place (about five seconds from keypress to the channel
restarting on the device), or start with `--watch` to reload automatically
two seconds after you save. `q` ends the session.

## `vibeview.json`

| Key | What it does |
|---|---|
| `defaultPlatform` | Platform `vibeview build` / `vibeview dev` use when `--platform` is omitted (`roku`). |
| `platforms.roku.appId` | The VibeView app record for this channel, written by the CLI after the first upload — you never type it. |
| `platforms.roku.build.command` | The shell command that packages the channel: it zips `manifest`, `source`, `components`, `images` and `data` into `out/signal.zip`, the sideload layout Roku's developer installer accepts. |
| `platforms.roku.build.artifact` | The zip that command produces; `vibeview dev` uploads it on every reload. |

`out/` and `.vibeview/` (the CLI's local session state) are ignored by git.

## Verifying it on a Roku yourself

Every control has a stable SceneGraph `id`, and `vibeview find "<id>"`
resolves it: `home.title`, `home.search`, `row.new`, `row.talk`,
`tile.<id>`, `home.saved.count`, `detail.title`, `detail.play`,
`detail.save`, `detail.nowplaying`, `search.input`, `search.keyboard`,
`search.results`. Focused elements are marked `[focused]` in the tree. On
Roku the remote buttons are `up`, `down`, `left`, `right`, `select` and
`back`.

```bash
vibeview dev --platform roku --detach --json
# → {"event":"session_ready","session_id":"…","url":"https://vibeview.io/sandbox/…"}
S=<session_id>

vibeview ui-tree --session $S                     # tile.tidewater-hours is [focused]; "Saved: 0 shows"
vibeview press right --session $S                 # ~ tile.long-rehearsal focused, tile.tidewater-hours unfocused
vibeview press down --session $S                  # ~ tile.two-chairs focused (first Talk tile)
vibeview find "tile.answering-machine" --session $S
vibeview tap-focused @<ref> --session $S          # Detail: "Answering Machine", detail.play focused
vibeview find "detail.save" --session $S
vibeview focus @<ref> --session $S                # focus moves without selecting
vibeview press select --session $S                # button now reads "Saved"
vibeview press back --session $S                  # Home; focus on that tile; "Saved: 1 show"

vibeview press up --session $S                    # twice: row above, then the Search button
vibeview press up --session $S
vibeview press select --session $S                # Search; the keyboard is focused
vibeview type "ti" --session $S                   # search.input reads "ti"; four results
vibeview find "tile.tidewater-hours" --session $S
vibeview focus @<ref> --session $S                # walks from the keyboard into the results
vibeview press select --session $S                # Detail: "Tidewater Hours"
vibeview press back --session $S                  # Search, then Home with the Search button focused
vibeview press back --session $S

vibeview tap-focused @<tile.answering-machine> --session $S
vibeview press select --session $S                # Play → "Now playing: Answering Machine"
vibeview wait --ms 5000 --session $S              # …and it is gone
vibeview screenshot --out check.png --session $S

vibeview dev-stop                                 # always: a running session bills minutes
```

Back on the Home screen is left to the platform, so it exits the channel
as any Roku channel does; a VibeView session brings the channel straight
back.

## Licence

MIT — see `LICENSE`.
