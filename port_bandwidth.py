class PortBandwidth:
    def __init__(self, port):
        super().__init__()
        self._port_id = port
        self._tot_bytes = 0
        self._sec = 0

    def __str__(self):
        return "Port {} bandwidth: {}B/s".format(self.port_id, self.bandwidth)

    def __repr__(self):
        return "{}: {}B/s".format(self.port_id, self.bandwidth)

    @property
    def tot_bytes(self):
        return self._tot_bytes

    @property
    def sec(self):
        return self._sec

    @property
    def bandwidth(self):
        if self.sec == 0:
            return 0
        else:
            return self.tot_bytes / self.sec

    @property
    def port_id(self):
        return self._port_id

    @tot_bytes.setter
    def tot_bytes(self, value):
        if value >= 0:
            self._tot_bytes = value

    @sec.setter
    def sec(self, value):
        if value >= 0:
            self._sec = value

    def clear(self):
        self.tot_bytes = 0
        self.sec = 0
