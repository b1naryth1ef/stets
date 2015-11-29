import json

class JSONDelegation():
    def __init__(self):
        self.data = []

    def event_to_json(self, event):
        return {
            'ts': event.timestamp(),
            'name': event.name,
            'data': event.data.__dict__
        }

    def wildcard(self, event):
        self.data.append(self.event_to_json(event))

    def dump(self):
        return json.dumps(self.data)
