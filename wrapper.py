#!/usr/bin/python3
from signal import signal, SIG_IGN, SIGTERM
import subprocess
import sys

def ignoreSigterm():
    signal(SIGTERM, SIG_IGN)

#Run the arguments as a command
args = sys.argv[1:]
process = subprocess.Popen(args = args, stdin = subprocess.PIPE, preexec_fn = ignoreSigterm)

def handleSigterm(signalNumber, frame):
    process.stdin.write(b'stop\n')
    process.stdin.flush()

#Intercept SIGTERM to send 'stop'
signal(SIGTERM, handleSigterm)
try:
  process.wait()
except KeyboardInterrupt:
  print('Server stopped')

sys.exit(process.returncode)
