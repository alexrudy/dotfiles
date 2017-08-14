#!/usr/bin/env python3
"""
A tool to keep a SSH tunnel open.
"""

import click
import subprocess
import datetime as dt
import logging
import logging.handlers
import os
import sys
import time
import curses
import select
import functools
    
def int_or_pair(value):
    """Integer, or a pair of integers."""
    if "," in value:
        s, d = value.split(",")
        return int(s), int(d)
    return int(value)

class _Terminfo:
    def __init__(self):
        self.__tty = os.isatty(sys.stdout.fileno())
        if self.__tty:
            curses.setupterm()
        self.__ti = {}

    def __ensure(self, cap):
        if cap not in self.__ti:
            if not self.__tty:
                string = None
            else:
                string = curses.tigetstr(cap)
                if string is None or b'$<' in string:
                    # Don't have this capability or it has a pause
                    string = None
            self.__ti[cap] = string
        return self.__ti[cap]

    def has(self, *caps):
        return all(self.__ensure(cap) is not None for cap in caps)

    def send(self, *caps):
        # Flush TextIOWrapper to the binary IO buffer
        sys.stdout.flush()
        for cap in caps:
            # We should use curses.putp here, but it's broken in
            # Python3 because it writes directly to C's buffered
            # stdout and there's no way to flush that.
            if isinstance(cap, tuple):
                s = curses.tparm(self.__ensure(cap[0]), *cap[1:])
            else:
                s = self.__ensure(cap)
            sys.stdout.buffer.write(s)
terminfo = _Terminfo()

class StatusMessage:
    _enabled = None

    def __init__(self, stream):
        self.__stream = stream
        if self._enabled is None:
            type(self)._enabled = terminfo.has('cr', 'el', 'rmam', 'smam')

    def __enter__(self):
        self.last = ''
        self.update('')
        return self

    def __exit__(self, typ, value, traceback):
        if self._enabled:
            # Beginning of line and clear
            terminfo.send('cr', 'el')
            self.__stream.flush()

    def update(self, msg):
        if not self._enabled:
            return
        if msg != self.last:
            # Beginning of line, clear line, disable wrap
            terminfo.send('cr', 'el', 'rmam')
            self.__stream.write(msg)
            # Enable wrap
            terminfo.send('smam')
            self.last = msg
            self.__stream.flush()
        
    

def setup_logging():
    """Set up the loggers"""
    root = logging.getLogger()
    logdir = os.path.join(os.path.expanduser("~"),".jt")
    
    h = logging.FileHandler(os.path.join(logdir, 'jt.log'), mode='w')
    f = logging.Formatter("[%(asctime)s] %(message)s")
    h.setFormatter(f)
    h.setLevel(logging.INFO)
    root.addHandler(h)
    
    os.makedirs(logdir, exist_ok=True)
    ssh = logging.getLogger("ssh")
    ssh_handler = logging.handlers.RotatingFileHandler(os.path.join(logdir, 'ssh.log'), mode='w')
    ssh_formatter = logging.Formatter("%(msg)s [%(asctime)s]")
    ssh_handler.setFormatter(ssh_formatter)
    ssh_handler.setLevel(logging.DEBUG)
    ssh.addHandler(ssh_handler)
    ssh.setLevel(logging.DEBUG)

# Sentinels for the class below.
_timedout = object()
_eof = object()      

class ContinuousSSH(object):
    """Continuos process management."""
    def __init__(self, args, stream):
        super(ContinuousSSH, self).__init__()
        self.args = args
        self._status = ""
        self._messenger = StatusMessage(stream)
        self._logger = logging.getLogger('ssh')
        self._handler = self._logger.handlers[0]
        self.status("disconnected", fg='red')
        
    def status(self, msg, **kwargs):
        """Status"""
        kwargs.setdefault('reset', True)
        self._status = click.style(msg, **kwargs)
        
    def update(self, msg):
        """Update the message line."""
        self._messenger.update("[{0:s}] {1}".format(self._status, msg))
    
    def run(self):
        """Run the continuous process."""
        try:
            with self._messenger:
                while True:
                    self._run_once()
        except KeyboardInterrupt:
            pass
            
    def _await_output(self, stream, timeout=None, timeout_callback=None):
        """Await output from the stream"""
        while True:
            if timeout is None:
                r, _, _ = select.select([stream], [], [])
            else:
                r, _, _ = select.select([stream], [], [], timeout)
            if r:
                line = stream.readline()
                if line == "":
                    break
                yield line.strip(b'\r\n').strip()
            elif timeout_callback is not None:
                timeout_callback()
        
    def _run_once(self):
        """Run the SSH process once"""
        proc = subprocess.Popen(self.args, stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
        try:
            self.status("connecting", fg='yellow')
            for line in self._await_output(proc.stdout, timeout=1.0, timeout_callback=functools.partial(self.update, "")):
                line = line.decode('utf-8', 'backslashreplace').strip()
                if line.startswith("debug1:"):
                    line = line[len("debug1:"):].strip()
                    self._logger.debug(line)
                else:
                    self._logger.info(line)
                if "Entering interactive session" in line:
                    self.status("connected", fg='green')
                self.update(line)
            proc.wait()
            self.status("disconnected", fg='red')
            self._handler.doRollover()
        finally:
            if proc.returncode is None:
                proc.terminate()
        
        

@click.command()
@click.option('-p', '--port', 'ports', default=8090, type=int_or_pair, multiple=True,
              help='Port to forward from the remote machine to the local machine')
@click.option('-k', '--interval', default=5, type=int, 
              help='Interval, in seconds, to use for maintaining the ssh connection.')
@click.argument('host')
def main(host, ports, interval):
    """Run an SSH tunnel over specified ports to HOST.
    
    Using the ssh option 'ServerAliveInterval', this script will keep the SSH tunnel alive
    and respawn a new tunnel if the old one dies.
    
    To forward ports 80 and 495 from mysever.com to localhost, you would use:
    
    jt -p 80 -p 495 myserver.com
    
    """
    setup_logging()
    log = logging.getLogger('jt')
    
    forward_template = '{0:d}:localhost:{0:d}'
    ssh_args = ['ssh', '-v', '-N', '-o', 'ServerAliveInterval {}'.format(interval)]
    for port in set(ports):
        ssh_args.extend(["-L", forward_template.format(port)])
    ssh_args.append(host)
    log.debug("args = %r", ssh_args)
    proc = ContinuousSSH(ssh_args, click.get_text_stream('stdout'))
    click.echo("Use ^C to exit")
    proc.run()
    click.echo("Done")    

if __name__ == '__main__':
    main()
    
