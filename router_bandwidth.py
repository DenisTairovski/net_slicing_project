class RouterManager:
    def __init__(self, router, preferred, excluded_ports=None):
        """
        Manages the traffic going through the ports of the router

        :param router: identifier of the router
        :param preferred: default port on which the extra traffic will be forwarded
        :param excluded_ports: ports that will be ignored in the bandwidth calculation
        """
        super().__init__()
        if excluded_ports is None:
            excluded_ports = [1, ]
        self._router_id = router
        self._ports = {}
        # ignore router-router ports
        self._ignored = excluded_ports
        self._secondary_port = preferred
        self.load_balancing = False

    def __contains__(self, item):
        return item.port_id in self.port_ids

    def __setitem__(self, key, value):
        """
        Set the port with the given id

        :param key: id of the port
        :param value: port object
        """
        self._ports[key] = value

    def __getitem__(self, key):
        return self._ports[key]

    def __len__(self):
        """

        :return: number of ports
        """
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
        return list(self._ports.keys())
