import re, sys

from collections import defaultdict

from event import Event
from state import *


class EOF(IOError):
    pass

class Parser(object):
    LINE_RE = re.compile("\[([\d]+)\-([\d]+)\] (\w+)(.+)?")

    def __init__(self, fobj):
        self.obj = fobj
        self.cbs = defaultdict(list)
        self.dels = []

    def delegate(self, d):
        self.dels.append(d)

    def on(self, event, f):
        self.cbs[event].append(f)

    def parseLine(self):
        line = self.obj.readline()

        if not line:
            raise EOF("No more lines to parse")

        data = self.LINE_RE.findall(line.strip())
        if len(data) != 1:
            raise Exception("Failed to regex parse line `%s`" % line.strip())

        event = Event(data[0])
        if event.name in self.cbs:
            map(lambda i: i(event), self.cbs[event.name])

        for d in self.dels:
            if hasattr(d, event.name):
                getattr(d, event.name)(event)
            if hasattr(d, "wildcard"):
                d.wildcard(event)

    def parse(self):
        while True:
            try:
                self.parseLine()
            except EOF:
                break

if __name__ == "__main__":
    from delegates.tojson import JSONDelegation
    to_json = JSONDelegation()

    parser = Parser(open(sys.argv[1], 'r'))
    parser.delegate(to_json)
    parser.parse()

    with open(sys.argv[2], 'w') as f:
        f.write(to_json.dump())

