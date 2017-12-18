#!/usr/bin/env python3
"""
A tool to keep a SSH tunnel open.

To use this tool, you need to install `click` and have a working python3 
installation. Check both by running:
    
    python3 -m pip install click
    

Afterwards, to use this tool, run:
    
    python3 jt.py --help
    
Or, for even more ergonmic use, mark this file as executable, and put
it somewhere on your path:
    
    mv jt.py ~/.bin/jt.py
    chmod +x ~/.bin/jt.py
    jt.py --help

For really simple usage, check out the `--auto` flag. To forward all of your
jupyter notebooks from a host `mymachine`, you would run:
    
    jt.py mymachine --auto


"""

import click
import subprocess
import datetime as dt
import logging
import logging.handlers
import os
import sys
import json
import time
import curses
import shlex
import selectors
import functools
import contextlib
from time import time as _time
from time import sleep
    
def int_or_pair(value):
    """Integer, or a pair of integers."""
    if isinstance(value, int):
        return value
    elif isinstance(value, tuple):
        return value
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
    os.makedirs(logdir, exist_ok=True)
    
    # Logger for the master process.
    h = logging.FileHandler(os.path.join(logdir, 'jt.log'), mode='w')
    f = logging.Formatter("[%(levelname)-8s %(asctime)s] %(message)s [%(name)s]")
    h.setFormatter(f)
    h.setLevel(logging.DEBUG)
    root.setLevel(logging.DEBUG)
    root.addHandler(h)
    
    # Logger for each subprocess.
    ssh = logging.getLogger("ssh")
    ssh_handler = logging.handlers.RotatingFileHandler(os.path.join(logdir, 'ssh.log'), mode='w')
    ssh_formatter = logging.Formatter("[%(levelname)-8s %(asctime)s] %(message)s [%(name)s]")
    ssh_handler.setFormatter(ssh_formatter)
    ssh_handler.setLevel(logging.DEBUG)
    ssh.addHandler(ssh_handler)
    ssh.setLevel(logging.DEBUG)
    ssh.propagate = False

def format_timedelta(td):
    """Format a time-delta into hours/minutes/seconds"""
    hr = td.seconds // 3600
    mn = (td.seconds // 60) - (hr * 60)
    s = td.seconds % 60
    return "{:d}:{:02d}:{:02d}".format(hr, mn, s)

# Sentinels for the class below.
_timedout = object()
_eof = object()      

class ContinuousSSH(object):
    """Continuos process management."""
    def __init__(self, args, stream):
        super(ContinuousSSH, self).__init__()
        self.args = args
        self._status = ""
        self._change = None
        self._messenger = StatusMessage(stream)
        self._logger = logging.getLogger('ssh')
        self._loggerjt = logging.getLogger('jt.ssh')
        self._handler = self._logger.handlers[0]
        self._popen_settings = {'bufsize':0}
        self._max_backoff_time = 1.0
        self._backoff_time = 0.1
        self._last_proc = None
        self.status("disconnected", fg='red')
        
    def status(self, msg, **kwargs):
        """Status"""
        kwargs.setdefault('reset', True)
        self._status = click.style(msg, **kwargs)
        self._change = dt.datetime.now()
        
    def update(self, msg):
        """Update the message line."""
        td = dt.datetime.now() - self._change
        self._messenger.update("[{0:s}] {1} | {2}".format(self._status, format_timedelta(td), msg))
    
    def run(self):
        """Run the continuous process."""
        try:
            with self._messenger:
                while True:
                    self._last_proc = _time()
                    self._run_once()
                    if (_time() - self._last_proc) < self._backoff_time:
                         sleep(self._backoff_time - (_time() - self._last_proc))
                         self._backoff_time = min(2.0 * self._backoff_time, self._max_backoff_time)
                    else:
                         self._backoff_time = 0.1
        except KeyboardInterrupt:
            pass
    
    def timeout(self):
        """Handle timeout"""
        self.update('')
            
    def _await_output(self, proc, timeout=None):
        """Await output from the stream"""
        endtime = _time() + timeout
        sel = selectors.DefaultSelector()
        with contextlib.closing(sel):
            sel.register(proc.stdout, selectors.EVENT_READ)
            while (proc.returncode is None):
                events = sel.select(timeout=timeout)
                for (key, event) in events:
                    if key.fileobj is proc.stdout:
                        line = proc.stdout.readline()
                        if line:
                            yield line.decode('utf-8', 'backslashreplace').strip('\r\n').strip()
                            endtime = _time() + timeout
                if _time() > endtime:
                    self.timeout()
                proc.poll()
        
    def _run_once(self):
        """Run the SSH process once"""
        proc = subprocess.Popen(self.args, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, **self._popen_settings)
        log = self._logger.getChild(str(proc.pid))
        self._loggerjt.info('Launching proc = {}'.format(proc.pid))
        try:
            self._loggerjt.debug('Connecting proc = {}'.format(proc.pid))
            self.status("connecting", fg='yellow')
            for line in self._await_output(proc, timeout=1.0):
                if line.startswith("debug1:"):
                    line = line[len("debug1:"):].strip()
                    log.debug(line)
                else:
                    log.info(line)
                if "Entering interactive session" in line:
                    self.status("connected", fg='green')
                    self._loggerjt.debug('Connected proc = {}'.format(proc.pid))
                if "not responding" in line:
                    self.status("disconnected", fg='red')
                    log.debug("Killing proc = {}".format(proc.pid))
                    self._loggerjt.debug('Killing proc = {}'.format(proc.pid))
                    proc.kill()
                self.update(line)
            log.info("Waiting for process to end.".format(proc.pid))
            proc.wait()
            self.status("disconnected", fg='red')
            self._handler.doRollover()
        finally:
            if proc.returncode is None:
                proc.terminate()
            self._loggerjt.debug('Ended proc = {}'.format(proc.pid))
        
def iter_json_data(output):
    """Iterate through decoded JSON information ports"""
    log = logging.getLogger("jt.auto")
    
    for line in output.splitlines():
        if line.strip(b"\r\n").strip():
            log.debug("JSON payload = {0!r}".format(line.decode('utf-8', 'backslashreplace')))
            try:
                data = json.loads(line)
                data['full_url'] = "http://localhost:{port:d}/?token={token:s}".format(**data)
            except json.JSONDecodeError:
                log.exception("Couldn't parse {0!r}".format(line.decode('utf-8', 'backslashreplace')))
            else:
                log.debug("parsed port = {0}".format(data['port']))
                log.debug("jupyter url = {!r}".format(data['full_url']))
                yield data

def get_relevant_ports(host, restrict_to_user=True, show_urls=True):
    """Get relevant port numbers for jupyter notebook services"""
    log = logging.getLogger("jt.auto")
    
    pgrep_string = "python3? .*jupyter-notebook"
    pgrep_args = ['pgrep', '-f', shlex.quote(pgrep_string), '|', 'xargs', 'ps', '-o', 'command=', '-p']
    if restrict_to_user:
        pgrep_args.insert(1, '-u$(id -u)')
    ssh_pgrep_args = ['ssh', host, ' '.join(pgrep_args)]
    ports = set()
    log.debug('ssh pgrep args = {!r}'.format(pgrep_args))
    procs = subprocess.check_output(ssh_pgrep_args)
    if show_urls:
        click.echo("Locating jupyter notebooks on {}".format(host))
    for proc in procs.splitlines():
        parts = shlex.split(proc.decode('utf-8', 'backslashreplace'))
        python = parts[0]
        if "pgrep" in parts and pgrep_string in parts:
            continue
        if parts[0] == 'xargs':
            continue
        log.debug("Python candidate = {0!r}".format(parts))
        for p in parts[1:]:
            if 'jupyter-notebook' in p:
                jupyter = p
                break
        else:
            raise ValueError("Can't find jupyter notebook in process {0}".format(proc))
        cmd = python, jupyter, 'list', '--json'
        ssh_juptyer_args = ['ssh', host, " ".join(shlex.quote(cpart) for cpart in cmd)]
        log.debug('ssh jupyter args = {!r}'.format(ssh_juptyer_args))
        output = subprocess.check_output(ssh_juptyer_args)
        for data in iter_json_data(output):
            if data['port'] not in ports:
                ports.add(data['port'])
                if show_urls:
                    click.echo("{:d}) {full_url:s} ({notebook_dir:s})".format(len(ports), **data))
    log.info("Auto-discovered ports = {0!r}".format(ports))
    return ports

@click.command()
@click.option('-p', '--port', 'ports', default=[8090], type=int_or_pair, multiple=True,
              help='Port to forward from the remote machine to the local machine. To forward to a different port, pass the ports as `remote,local`.')
@click.option('-k', '--interval', default=5, type=int, 
              help='Interval, in seconds, to use for maintaining the ssh connection (see ServerAliveInterval)')
@click.option('--connect-timeout', default=10, type=int, 
              help="Timeout for starting ssh connections (see ConnectTimeout)")
@click.option('--auto/--no-auto', help='Automatically detect ports in use by jupyter on the remote host.')
@click.option('--auto-restrict-user/--no-auto-restrict-user', default=True,
              help='Restrict automatic decection to the user ID. (default=True) Turning this off will try to forward ports for all users on the remote host.')
@click.argument('host')
def main(host, ports, interval, connect_timeout, auto, auto_restrict_user):
    """Run an SSH tunnel over specified ports to HOST.
    
    Using the ssh option 'ServerAliveInterval', this script will keep the SSH tunnel alive
    and respawn a new tunnel if the old one dies.
    
    To forward ports 80 and 495 from mysever.com to localhost, you would use:
    
    jt.py -p 80 -p 495 myserver.com
    
    To stop the SSH tunnel, press ^C.
    """
    setup_logging()
    log = logging.getLogger('jt')
    
    if auto:
        try:
            ports = get_relevant_ports(host, auto_restrict_user)
        except subprocess.CalledProcessError as e:
            click.echo("[{}] Collecting ports for forwarding: {!r}".format(click.style("ERROR", fg='red'), e.msg))
        
        if not ports:
            click.echo("No jupyter open ports found.")
            raise click.Abort()
        
        click.echo("Forwarding ports {0}".format(", ".join("{:d}".format(p) for p in ports)))
        
    forward_template = '{0:d}:localhost:{1:d}'
    ssh_args = ['ssh', '-v', '-N', 
                '-o', 'ServerAliveInterval {:d}'.format(interval),
                '-o', 'ConnectTimeout {:d}'.format(connect_timeout)]
    if not ports:
        click.echo("[{}] No ports selected for forwarding!".format(click.style("WARNING", fg='yellow')))
        
    
    for port in set(ports):
        if isinstance(port, int):
            ssh_args.extend(["-L", forward_template.format(port, port)])
        else:
            ssh_args.extend(["-L", forward_template.format(*port)])
    ssh_args.append(host)
    log.debug("ssh forwarding args = %r", ssh_args)
    proc = ContinuousSSH(ssh_args, click.get_text_stream('stdout'))
    click.echo("Use ^C to exit")
    proc.run()
    click.echo("Done")    

if __name__ == '__main__':
    main()
    
