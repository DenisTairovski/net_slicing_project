class PortBandwidth:
    def __init__(self, port, tot_bytes=0, seconds=0):
        super().__init__()
        self._port_id = port
        self._tot_bytes = tot_bytes
        self._sec = seconds
        self._new_bytes = 0

    def __str__(self):
        return "Port {} bandwidth: {}B/s".format(self.port_id, self.bandwidth)

    def __repr__(self):
        return "{}: {} B/s".format(self.port_id, self.bandwidth)

    def __copy__(self):
        return type(self)(self.port_id, self._tot_bytes, self.sec)

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
            return round(self._new_bytes / self.sec, 3)

    @property
    def port_id(self):
        return self._port_id

    @tot_bytes.setter
    def tot_bytes(self, value):
        if value >= 0:
            self._new_bytes = value - self._tot_bytes
            self._tot_bytes = value

    @sec.setter
    def sec(self, value):
        if value >= 0:
            self._sec = value

    def clear(self):
        """
        Reset the byte counter and elapsed time
        :return:
        """
        self.tot_bytes = 0
        self.sec = 0
