#replacement for Tk classes

NONE=None

class IntVar:
    def __init__(self):
        self.i = 0
    def set(self, i):
        self.i = int(i)
    def get(self):
        return self.i

class StringVar:
    def __init__(self):
        self.i = ''
    def set(self, i):
        self.i = i
    def get(self):
        return self.i

# Sivan: seems that newly created DoubleVar's contain a string, not a float 0.0. Strange
class DoubleVar:
    def __init__(self):
        self.i = 0.0
    def set(self, i):
        self.i = float(i)
    def get(self):
        return self.i

