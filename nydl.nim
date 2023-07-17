import std/[os,strformat,strutils]
import commandeer

proc exec(cmd: string): string = 
  let output = getTempDir()/"ydl_out"
  let command = fmt"{cmd} > {output}"
  discard execShellCmd(command)
  result = readFile(output)
  removeFile(output)

let
  musics_path = getEnv("MUSICS", getHomeDir()/"Music"/"Musics")
  usage = """
Usage: ydl [COMMAND] [PARAMETERS]

Commands:
  play             # start the music player
  add  [URL]       # add music from URL
  rem              # remove music by name using fzf
  search           # search for music in the library
  sync [get/give]  # sync the music with the server
  help [COMMAND]   # Describe available commands or one specific command"""

commandline:
  # start ncmpcpp
  subcommand play, "play": discard
  # add music from url
  subcommand add, "add":
    argument url, string
  # remove music using fzf
  subcommand rem, "rem": discard
  # search music using fzf
  subcommand search, "search": discard
  # sync music as client or server
  subcommand sync, "sync":
    argument action, string
  # show help and usage
  exitoption "help", "h", usage
  errormsg usage

# start the music player
if play:
  quit execShellCmd("ncmpcpp")
# download music from youtube
elif add:
  discard exec(fmt"yt-dlp -x --audio-format mp3 {url}")
  var file = exec("ls *.mp3")
  file.removeSuffix()
  moveFile(file, musics_path/file)
# remove a music from the library
elif rem:
  let to_delete = exec(fmt"ls {musics_path} | fzf")
  if to_delete != "":
    removeFile(musics_path/to_delete)
# simple search through musics
elif search:
  discard exec(fmt"ls {musics_path} | fzf")
# act as client or server to sync musics
# TODO
elif sync:
  discard
# no command provided
else:
  quit usage, 0
