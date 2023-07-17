# Package
version       = "0.1.0"
author        = "azz"
description   = "Musics library manager"
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["nydl"]

# tasks
import std/[strformat]
before build:
  when defined(windows) and defined(x86_64):
    const yt_url = "https://github.com/yt-dlp/yt-dlp/releases/download/2023.07.06/yt-dlp.exe"
  when defined(linux) and defined(x86_64):
    const yt_url = "https://github.com/yt-dlp/yt-dlp/releases/download/2023.07.06/yt-dlp"
  exec fmt"wget {yt_url} -O yt 2> /dev/null"
  exec "ls -lah"

after build:
  exec "rm yt"

# Dependencies
requires "nim >= 1.6.14"
requires "commandeer"
