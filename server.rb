require 'socket'

socket = TCPServer.new(80)

loop do
  client = socket.accept
  first_line = client.gets
  verb, path, _ = first_line.split

  if verb == 'GET'
    response = "HTTP/1.1 200\r\n\r\nHello!"
    client.puts(response)
  end

  client.close
end

socket.close