import std/[os,strformat,strutils,logging]
import commandeer
import client
import server

# execute shell commande and return stdout
proc exec(cmd: string): string = 
  let output = getTempDir()/"ydl_out"
  let command = &"{cmd} > {output}"
  discard execShellCmd(command)
  result = readFile(output)
  removeFile(output)

let
  musics_path = getEnv("MUSICS_PATH", expandTilde("~/Music/Musics"))
  default_player = getEnv("MUSIC_PLAYER", "ncmpcpp")
  usage = """
Usage: ydl [COMMAND] [PARAMETERS]

Commands:
  play             # start the music player
  add  [URL]       # add music from URL
  rem              # remove music by name using fzf
  search           # search for music in the library
  sync [get/give]  # sync the music with the server
  help             # show this help"""

# create Music path
createDir(musics_path)

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

addHandler(newConsoleLogger())
# start the music player
if play:
  quit execShellCmd(default_player)
# download music from youtube
elif add:
  try:
    info &"Downloading {url}"
    if exec(&"yt-dlp -x --audio-format mp3 {url}").contains("generic"): raise
    info &"Downloaded {url}"
    var file = exec("ls *.mp3")
    file.removeSuffix()
    info &"Mp3: {file}"
    moveFile(file, musics_path/file)
    info &"Moving \"{file}\" to \"{musics_path/file}\""
    info &"\"{file}\" added to the library with success :)"
  except CatchableError as e:
    quit &"Couldn't download music: {e.msg} :("
# remove a music from the library
elif rem:
  var to_delete = exec(&"ls {musics_path} | fzf")
  to_delete.removeSuffix()
  if to_delete != "":
    removeFile(musics_path/to_delete)
    info &"Deleted \"{to_delete}\" with success :)"
# simple search through musics
elif search:
  discard exec(&"ls {musics_path} | fzf")
# act as client or server to sync musics
elif sync:
  if action == "give": startServer(musics_path)
  elif action == "get": startClient(musics_path)
  else: quit usage, 1
# no command provided
else:
  quit usage, 0
