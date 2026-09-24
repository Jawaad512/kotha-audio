# kotha-audio

Static host for audio assets used by a **captioned phone call prototype** built on Twilio.

Twilio's `<Play>` verb needs each clip at a public HTTPS URL it can fetch mid-call.
This repo is published with GitHub Pages, so every file committed to the root of
`main` is served over HTTPS within about a minute.

## Using a clip in TwiML

```xml
<Response>
  <Play>https://jawaad512.github.io/kotha-audio/TTStest.mpga</Play>
</Response>
```

Note the **`.mpga`** extension - see below.

## Why .mpga and not .mp3

GitHub Pages picks the `Content-Type` from the file extension and gives no way to
override it. It serves `.mp3` as `audio/mp3`, a non-standard alias that is **not**
among the content types Twilio documents as supported for `<Play>`, and which can
surface as Twilio error 12300 (invalid content type).

`.mpga` is served as `audio/mpeg`, which *is* supported. Verified against this repo:

| Extension | Content-Type from GitHub Pages |
| --- | --- |
| `.mp3` | `audio/mp3` |
| `.mpga` | `audio/mpeg` ← use this |
| `.mp2`, `.m2a` | `audio/mpeg` |
| `.mpeg` | `video/mpeg` |
| `.mpa` | `application/octet-stream` |

So every clip is published twice: `name.mp3` and a byte-identical `name.mpga`.
The `.mp3` stays for browsers and humans; the `.mpga` is what goes in TwiML.
`add-audio.sh` creates and maintains the twins automatically - you never make
them by hand.

A `_headers` file would not help here: that's a Netlify / Cloudflare Pages
feature and GitHub Pages ignores it.

## Adding more clips

```bash
./add-audio.sh path/to/greeting.mp3 path/to/test-phrase.mp3
```

Copies the files in, creates the `.mpga` twins, commits, pushes to `main`, and
prints the Twilio URL for every clip in the repo. Run it with no arguments to
publish files you've already dropped into this folder by hand.

## Layout

| File | Purpose |
| --- | --- |
| `*.mp3` | The clips as you added them - greetings, test phrases, TTS output |
| `*.mpga` | Byte-identical twins that serve as `audio/mpeg`, for Twilio |
| `add-audio.sh` | One-command publish |
| `.nojekyll` | Serve files as-is instead of running them through Jekyll |
| `.gitattributes` | Marks audio binary so Windows line-ending conversion can't corrupt it |

## Notes

- Everything here is public. Don't commit anything sensitive - no caller audio,
  no recordings of real conversations.
- Keep clips small. They're fetched during a live call, so latency matters.
- Pages caches for 10 minutes (`Cache-Control: max-age=600`). If you replace a
  clip in place, expect up to that long before Twilio sees the new version;
  publishing under a new filename avoids the wait entirely.
