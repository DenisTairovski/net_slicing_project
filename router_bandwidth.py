class RouterManager:
    def __init__(self, router, preferred, excluded_ports=None):
        super().__init__()
        if excluded_ports is None:
            excluded_ports = [1, ]
        self._router_id = router
        self._ports = {}
        # ignore router-router ports
        self._ignored = excluded_ports
        self._secondary_port = preferred

    def __contains__(self, item):
        return item.port_id in self.port_ids

    def __setitem__(self, key, value):
        # if value not in self:
        #     self.add_port(value)
        # else:
        #     self.ports[key] = value
        self._ports[key] = value

    def __len__(self):
        return len(self.ports)

    def __str__(self):
        return "Router {}: [{}]".format(self.router_id, [repr(p) for p in self.ports])

    @property
    def router_id(self):
        return self._router_id

    @property
    def secondary_port(self):
        return self._secondary_port

    @property
    def ignored(self):
        return self._ignored

    @property
    def ports(self):
        return list(self._ports.values())

    @property
    def port_ids(self):
        # return [port.port_id for port in self.ports]
        return list(self._ports.keys())

    # def add_port(self, port):
    #     self.ports.insert(port.port_id, port)

    def clear(self):
        for port in self.ports:
            port.clear()
