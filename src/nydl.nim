import std/[os,strformat,strutils,logging]
import commandeer
import puppy
import client
import server

# get yt-dlp if not found in the directory of nydl
# return the path to yt-dlp
proc download_yt_dlp(): string =
  let cwd = getAppDir()
  const url = "https://github.com/yt-dlp/yt-dlp/releases/download/2023.07.06/"
  when defined(windows) and defined(x86_64):
    let yt_url = url & "yt-dlp.exe"
    let yt_path = cwd/"yt-dlp.exe"
  when defined(linux) and defined(x86_64):
    let yt_url = url & "yt-dlp"
    let yt_path = cwd/"yt-dlp"
  if not fileExists(yt_path):
    writeFile(yt_path, fetch(yt_url))
    setFilePermissions(yt_path, {fpUserRead,fpUserWrite,fpUserExec})
  return yt_path

# execute shell commande and return stdout
proc exec(cmd: string): string = 
  let output = getTempDir()/"ydl_out"
  let command = fmt"{cmd} > {output}"
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

addHandler(newConsoleLogger())
# start the music player
if play:
  quit execShellCmd(default_player)
# download music from youtube
elif add:
  try:
    let yt = download_yt_dlp()
    info fmt"Downloading {url}"
    if exec(fmt"{yt} -x --audio-format mp3 {url}").contains("generic"): raise
    info fmt"Downloaded {url}"
    var file = exec("ls *.mp3")
    file.removeSuffix()
    moveFile(file, musics_path/file)
    info &"\"{file}\" added to the library with success :)"
  except:
    quit "Couldn't download music :("
# remove a music from the library
elif rem:
  var to_delete = exec(fmt"ls {musics_path} | fzf")
  to_delete.removeSuffix()
  if to_delete != "":
    removeFile(musics_path/to_delete)
    info &"Deleted \"{to_delete}\" with success :)"
# simple search through musics
elif search:
  discard exec(fmt"ls {musics_path} | fzf")
# act as client or server to sync musics
elif sync:
  if action == "give": startServer()
  elif action == "get": startClient()
  else: quit usage, 1
# no command provided
else:
  quit usage, 0
