# nydl

Music library manager and downloader

## requirement

Might require python3 to run [yt-dlp](https://github.com/yt-dlp/yt-dlp).  
Requires [fzf](https://github.com/junegunn/fzf) for the `rem` and `search` command.  

## usage

```
Usage: ydl [COMMAND] [PARAMETERS]

Commands:
  play             # start the music player
  add  [URL]       # add music from URL
  rem              # remove music by name using fzf
  search           # search for music in the library
  sync [get/give]  # sync the music with the server
  help [COMMAND]   # Describe available commands or one specific command
```

- `MUSICS_PATH` env variable to set the music library path
- `MUSIC_PLAYER` env variable to set the music player (ncmpcpp as default)
