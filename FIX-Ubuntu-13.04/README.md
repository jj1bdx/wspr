# bugfix for WSPR on Python PIL (Pillow) of Ubuntu 13.04

The following bug is found on Ubuntu 13.04:

        Exception in Tkinter callback
        Traceback (most recent call last):
          File "/usr/lib/python2.7/lib-tk/Tkinter.py", line 1473, in __call__
            return self.func(*args)
          File "/usr/lib/python2.7/lib-tk/Tkinter.py", line 534, in callit
            func(*args)
          File "wspr.py", line 1228, in update
            draw.text((x,148),tw[i],fill=253)        #Insert time label
          File "/usr/lib/python2.7/dist-packages/PIL/ImageDraw.py", line 256, in text
            ink, fill = self._getink(fill)
          File "/usr/lib/python2.7/dist-packages/PIL/ImageDraw.py", line 144, in _getink
            if self.palette and not Image.isNumberType(ink):
        AttributeError: 'module' object has no attribute 'isNumberType'
        
## How to fix

Replace `/usr/lib/python2.7/dist-packages/PIL/ImageDraw.py` by the file in this directory, which is copied from <https://github.com/python-imaging/Pillow/blob/1f41e25b4feec620ad32e8b3a9b28466f63b3afe/PIL/ImageDraw.py>
        
[end of memorandum]
