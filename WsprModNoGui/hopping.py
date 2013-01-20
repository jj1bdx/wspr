import os,time
import g
from tkrep import *

bandlabels=['dummy','600 m','160 m','80 m','60 m','40 m','30 m',\
            '20 m','17 m','15 m','12 m','10 m','6 m','4 m','2 m',\
            'Other']

coord_bands=IntVar()
coord_bands.set(1)
hopping=IntVar()
hopping.set(0)
hoppingconfigured=IntVar()
hoppingconfigured.set(0)
bhopping   =range(len(bandlabels))
shopping   =range(len(bandlabels))
lhopping   =range(len(bandlabels))
hoppingflag=range(len(bandlabels))
hoppingpctx=range(len(bandlabels))
btuneup    =range(len(bandlabels))
tuneupflag =range(len(bandlabels))

for r in range(1,16):
    hoppingflag[r] = IntVar()
    hoppingflag[r].set(0)
    hoppingpctx[r] = IntVar()
    hoppingpctx[r].set(0)
    tuneupflag[r] = IntVar()
    tuneupflag[r].set(0)

#def save_params(appdir):
#    f=open(appdir+'/hopping.ini',mode='w')
#    t="%d %d\n" % (hopping.get(),coord_bands.get())
#    f.write(t)
#    for r in range(1,16):
#        t="%4s %2d %5d %2d\n" % (bandlabels[r][:-2], hoppingflag[r].get(), \
#                                hoppingpctx[r].get(),tuneupflag[r].get())
#        f.write(t)
#    f.close()

def restore_params(appdir):
    if os.path.isfile(appdir+'/hopping.ini'):
        try:
            f=open(appdir+'/hopping.ini',mode='r')
            s=f.readlines()
            f.close()
            hopping.set(int(s[0][0:1]))
            coord_bands.set(int(s[0][2:3]))
            for r in range(1,16):
                hoppingflag[r].set(int(s[r][6:7]))
                hoppingpctx[r].set(int(s[r][8:13]))
                tuneupflag[r].set(int(s[r][13:16]))
            globalupdate()
        except:
            print 'Error reading hopping.ini.'
