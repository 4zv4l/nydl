# nydl

Music library manager and downloader

## requirement

Requires [yt-dlp](https://github.com/yt-dlp/yt-dlp) for the `add` command.  
Might require python3 to run [yt-dlp](https://github.com/yt-dlp/yt-dlp).  
Requires [fzf](https://github.com/junegunn/fzf) for the `rem` and `search` command.  
Requires [ncmpcpp](https://github.com/ncmpcpp/ncmpcpp) if you don't modify the `MUSIC_PLAYER` env variable.

## usage

```
Usage: ydl [COMMAND] [PARAMETERS]

Commands:
  play             # start the music player
  add  [URL]       # add music from URL
  rem              # remove music by name using fzf
  search           # search for music in the library
  sync [get/give]  # sync the music with the server
  help             # show this help
```

- `MUSICS_PATH` env variable to set the music library path
- `MUSIC_PLAYER` env variable to set the music player (ncmpcpp as default)
