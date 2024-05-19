class RouterManager:
    def __init__(self, router):
        super().__init__()
        self._router_id = router
        self._ports = []

    def __contains__(self, item):
        return item.port_id in self.port_ids

    def __len__(self):
        return len(self.ports)

    def __str__(self):
        return "Router {}: [{}]".format(self.router_id, [repr(p) + "," for p in self.ports])

    @property
    def router_id(self):
        return self._router_id

    @property
    def ports(self):
        return self._ports

    @ports.setter
    def ports(self, value):
        if len(value) > 0:
            self._ports = value

    @property
    def port_ids(self):
        return [port.port_id for port in self.ports]

    def add_port(self, port):
        if port not in self:
            self.ports.append(port)

    def clear(self):
        for port in self.ports:
            port.clear()
