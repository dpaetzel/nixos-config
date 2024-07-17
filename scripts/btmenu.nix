{ writeScriptBin, mypython, bluez, dmenu }:

(writeScriptBin "btmenu" ''
  #!${mypython}/bin/python

  import time
  import re
  from subprocess import Popen, PIPE
  import sys

  proc = Popen(["${bluez}/bin/bluetoothctl", "devices"],
               stdout=PIPE,
               stderr=PIPE)
  stdout, stderr = proc.communicate()
  stdout = stdout.decode().strip()
  stdout = stdout.split("\n")


  def parse_address_name(line):
      address, name = re.sub(r"Device ([^ ]*) (.*)", (r"\1#\2"), line).split("#")
      return name, address


  devs = dict([parse_address_name(line) for line in stdout if line])
  print(devs)

  disconnect = "Disconnect\n"

  proc = Popen(["${dmenu}/bin/dmenu"] + sys.argv[1:],
               stdin=PIPE,
               stdout=PIPE,
               stderr=PIPE)
  options = ("\n".join(list(devs.keys()) + [disconnect])).encode()
  stdout, stderr = proc.communicate(input=options)
  choice = stdout.decode().strip()

  if choice == disconnect.strip():
      for addr in devs.values():
          proc = Popen(["${bluez}/bin/bluetoothctl", "disconnect", addr])
          proc.communicate()
  else:
      # Always disconnect first. `bluetoothctl` is a bit weird in that regard.
      for addr in devs.values():
          proc = Popen(["${bluez}/bin/bluetoothctl", "disconnect", addr])
          proc.communicate()
          # If we're too fast then things don't seem to work.
          time.sleep(0.2)

      # If we're too fast then things don't seem to work.
      time.sleep(1.0)
      proc = Popen(["${bluez}/bin/bluetoothctl", "connect", devs[choice]])
      proc.communicate()
'')
