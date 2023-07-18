import std/[net, asyncnet, asyncdispatch, os, logging, strformat, strutils]

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
proc send_discovery(client: AsyncSocket, ip: string, port: Port) {.async.} =
  while true:
    asyncCheck client.sendTo(ip, port, "???")
    info "Sent discovery broadcast"
    await sleepAsync(1_000)
proc find_server_ip(): string =
  info "Looking for server(s)"
  var (ip, port) = ("255.255.255.255", Port(UDP_PORT))
  info &"Discovering on {ip}:{port}"
  let client = newAsyncSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
  client.setSockOpt(OptBroadcast, true)
  while true:
    debug "sending discovery message"
    asyncCheck send_discovery(client, ip, port)
    debug "sent discovery message"
    debug "waiting for response"
    let infos = waitFor client.recvFrom("ydl ok".len)
    debug &"got response: {infos.data}"
    if infos.data == "ydl ok":
      info &"Found a server at {infos.address}"
      return infos.address

proc startClient*(musics_path: string) =
  info &"Source directory is {musics_path}"
  if not dirExists(musics_path):
    createDir(musics_path)
    info &"Created {musics_path} because it didn't exist"
  let ip = find_server_ip()
  let client = newSocket(buffered=false)
  info &"Connecting to {ip}:{TCP_PORT}"
  client.connect(ip, Port(TCP_PORT))
  info &"Connected to {ip}:{TCP_PORT}"
  var counter = 0
  while (var path = client.recvLine(); path != ""):
    download_file(client, musics_path/path)
    counter += 1
  info &"Done downloading {counter} musics :)"
