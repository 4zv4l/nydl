import std/[net, os, threadpool, logging, strformat]

const
  UDP_PORT = 6666
  TCP_PORT = 6667

# send file to client
# server: filename
# server: size
# server: send(file, size)
proc upload_file(conn: Socket, path: string) =
  conn.send(extractFilename(path) & "\n")
  info &"sent path {extractFilename(path)}"
  conn.send($getFileSize(path) & "\n")
  info &"sent size {getFileSize(path)}"
  conn.send(readFile(path))
  info &"sent music"

# client discovery
# client: ???
# server: ydl ok
proc client_discovert() =
  addHandler(newConsoleLogger())
  var (ip, port) = ("0.0.0.0", Port(UDP_PORT))
  info fmt"Discovering on {ip}:{port}"
  let server = newSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
  server.setSockOpt(OptBroadcast, true)
  var data: string
  server.bindAddr(port, ip)
  while true:
    discard server.recvFrom(data, 1024, ip, port)
    if data != "???":
      debug fmt"Got {data} from {ip}:{port}"
      continue
    server.sendTo(ip, port, "ydl ok")
    info fmt"Sent discovery to client at {ip}:{port}"

proc startServer*() =
  # handle UDP client discovery
  spawn client_discovert()
  # handle TCP client download
  addHandler(newConsoleLogger())
  let musics_path = getEnv("MUSICS_PATH", expandTilde("~/Music/Musics/*.mp3"))
  let (ip, port) = ("0.0.0.0", Port(TCP_PORT))
  let server = newSocket(buffered=false)
  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr(port, ip)
  server.listen()
  info fmt"Listening on {ip}:{port}"
  # client loop
  while true:
    var client = newSocket()
    server.accept(client)
    var (client_ip, client_port) = client.getPeerAddr()
    info fmt"Got a client at {client_ip}:{client_port}"
    for music in walkPattern(musics_path):
      try: upload_file(client, music)
      except: break
    client.close
    info "Done with client :)"
