#--------------------------------------------------------------  user_hardware
import sys
from ctypes import windll,c_long,byref

iant= [16,32,64]
ib={600:1,160:2,80:3,60:4,40:5,30:6,20:7,17:8,15:9,12:10,10:11,6:12,4:13}
vertical=0
doublet=1
mosley=2
band=int(sys.argv[1])
nant=doublet                    #Default antenna is "doublet"
if band==160: nant=vertical
##if band==20 or band==15 or band==10:  nant=mosley
iband=ib[band]

# Fixed paremeters for LabJack:
idnum = c_long(-1)              #default labjack ID
demo = c_long(0)                #default 0
trisD = c_long(65535)
trisIO = c_long(15)
updateDigital = c_long(1)
outputD = c_long(0)

# LabJack band-select and other parameters
#   stateIO sets 4 bits, IO0 - IO3
#   stateD sets 16 bits, D0 - D15

iodata2=0
iodata=iant[nant]

# Any other LabJack commands should be OR'd into iodata here:

stateD=c_long(iodata)
stateIO=c_long(iodata2)
err = windll.ljackuw.DigitalIO(byref(idnum),demo,byref(trisD),trisIO, \
            byref(stateD),byref(stateIO),updateDigital,byref(outputD))
if err!=0:
    print 'Error executing Labjack command'
