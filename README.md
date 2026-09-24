# kotha-audio

Static host for audio assets used by a **captioned phone call prototype** built on Twilio.

Twilio's `<Play>` verb needs each clip at a public HTTPS URL it can fetch mid-call.
This repo is published with GitHub Pages, so every file committed to the root of
`main` is served over HTTPS a few seconds later.

## Using a clip in TwiML

```xml
<Response>
  <Play>https://USERNAME.github.io/kotha-audio/TTStest.mp3</Play>
</Response>
```

## Adding more clips

```bash
./add-audio.sh path/to/greeting.mp3 path/to/test-phrase.mp3
```

The script copies the files in, commits, pushes to `main`, and prints the public
URL for each one. Run it with no arguments to publish files you've already
dropped into this folder by hand.

## Layout

Audio files live at the repo root, which keeps the URLs short for TwiML.

| File | Purpose |
| --- | --- |
| `*.mp3` | The hosted clips - greetings, test phrases, TTS output |
| `add-audio.sh` | One-command publish: copy in, commit, push, print URLs |
| `.nojekyll` | Tells Pages to serve files as-is instead of running Jekyll |
| `.gitattributes` | Marks audio as binary so Windows line-ending conversion can't corrupt it |

## Notes

- Content type is set by GitHub Pages, which serves `.mp3` as `audio/mpeg`.
  A `_headers` file would **not** work here - that's a Netlify/Cloudflare Pages
  feature and GitHub Pages ignores it.
- Everything here is public. Don't commit anything sensitive - no caller audio,
  no recordings of real conversations.
- Keep clips small. These are fetched during a live call, so latency matters.
