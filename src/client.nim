import std/[net, os, logging, strformat, strutils]

const
  UDP_PORT = 6666
  TCP_PORT = 6667

proc download_file(conn: Socket, path: string) =
  info &"About to get \"{path}\""
  var size = parseUInt(conn.recvLine())
  info &"of size {size.int}"
  let mb_size = size div 1024 div 1024
  info &"Downloading \"{path}\" of size {mb_size} mb"
  var data: string
  var tmp_size = size.int
  while true:
    let tmp_data = conn.recv(tmp_size)
    tmp_size -= tmp_data.len
    data &= tmp_data
    if data.len == size.int: break
  writeFile(path, data)
  info &"Downloaded \"{path}\""

# server discovery
# client: ???
# server: ydl ok
# return server ip
proc find_server_ip(): string =
  info "Looking for server(s)"
  var (ip, port) = ("255.255.255.255", Port(UDP_PORT))
  var data: string
  info fmt"Discovering on {ip}:{port}"
  let client = newSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
  client.setSockOpt(OptBroadcast, true)
  while true:
    debug "sending discovery message"
    client.sendTo(ip, port, "???")
    debug "sent discovery message"
    debug "waiting for response"
    discard client.recvFrom(data, 1024, ip, port)
    debug fmt"got response: {data}"
    if data == "ydl ok":
      info fmt"Found a server at {ip}"
      return ip

proc startClient*() =
  addHandler(newConsoleLogger())
  let musics_path = getEnv("MUSICS_PATH", expandTilde("~/Music/Musics/*.mp3"))
  let ip = find_server_ip()
  let client = newSocket(buffered=false)
  client.connect(ip, Port(TCP_PORT))
  info "Connected to {ip}:{TCP_PORT}"
  var counter = 0
  while (var path = client.recvLine(); path != ""):
    download_file(client, musics_path/path)
    counter += 1
  info fmt"Done downloading {counter} musics :)"
