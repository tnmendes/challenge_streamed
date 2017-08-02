import socket
import sys
from time import sleep
import base64

if len(sys.argv) < 2:
  print('no port provided')
  sys.exit(1)

port = int(sys.argv[1])

# setup the server
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_address = ('', port)
sock.bind(server_address)
print('starting up on ', server_address)
print('waiting for first package to initialise connection')

# receive inital data to obtain client address
data, address = sock.recvfrom(4096)
print("got request from ", address)

def encode( cnt, data ):
  b_cnt = cnt.to_bytes(3, byteorder='big', signed=False)
  b_data = data.to_bytes(2, byteorder='big', signed=False)
  return base64.b64encode(b_cnt+b_data)

# read file continiuosly and wrap counter when end of file is reached
while True:
  cnt = 0
	
  with open('data.csv') as csvfile:
    for row in csvfile:
      data = encode(cnt, int(row))
      print("sending data: ", data)

      sock.sendto(data, address)

      cnt = cnt+1
      sleep(0.1)
