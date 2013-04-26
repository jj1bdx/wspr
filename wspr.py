#----------------------------------------------------------------------- WSPR
# $Date: 2008-03-17 08:29:04 -0400 (Mon, 17 Mar 2008) $ $Revision: 3015 $
#
# WSPR (pronounced "whisper") stands for "Weak Signal
# Propagation Reporter".  The program generates and decodes
# a digital soundcard mode optimized for beacon-like
# transmissions on the LF, MF, and HF bands.
#
# Copyright (c) 2008-2012 by Joseph H. Taylor, Jr., K1JT, with
# contributions from VA3DB, G4KLA, W1BW, and 4X6IZ.  WSPR is
# Open Source software, licensed under the GNU General Public
# License (GPL).  Source code and programming information may
# be found at http://developer.berlios.de/projects/wsjt/.
#
# Revision for MacOsX 10.6.8 by KE6HDU
# Apparently the tK library has a leak on MacOsX, so every extra call
# to that library has been suppressed.  This reduced memory use from
# 100KB/second to the point where memory is only lost when the window
# is updated for some reason.  This sort of loss is typically 100KB per 2 minutes
# or about 100 times slower than the original.  You can reduce even that
# by decreasing the sensitivity to noise changes.  This change also greatly
# reduced the load on the kernel, from a sustained 13% to essentially nothing.
# These changes are also licensed under the GNU General Public License (GPL).

from Tkinter import *
from tkFileDialog import *
import tkMessageBox
import os,time,sys
from WsprMod import g,Pmw
from WsprMod import palettes
from math import log10
try:
    from numpy.oldnumeric import zeros
except: 
    from Numeric import zeros
import array
import dircache
import Image, ImageTk, ImageDraw
from WsprMod.palettes import colormapblue, colormapgray0, colormapHot, \
     colormapAFMHot, colormapgray1, colormapLinrad, Colormap2Palette
from types import *
import array
import random
import math
import string
from WsprMod import w
from WsprMod import smeter
import socket
import urllib
import thread
import webbrowser

root = Tk()
Version="4.0 r" + "$Rev: 3015 $"[6:-2]
print "******************************************************************"
print "WSPR Version " + Version + ", by K1JT"
print "Run date:   " + time.asctime(time.gmtime()) + " UTC"

#See if we are running in Windows
g.Win32=0
if sys.platform=="win32":
    g.Win32=1
    try:
        root.option_readfile('wsprrc.win')
    except:
        pass
else:
    try:
        root.option_readfile('wsprrc')
    except:
        pass
root_geom=""
appdir=os.getcwd()
w.acom1.nappdir=len(appdir)
w.acom1.appdir=(appdir+(' '*80))[:80]
i1,i2=w.audiodev(0,2)
from WsprMod import options
from WsprMod import advanced
from WsprMod import iq
from WsprMod import hopping

#------------------------------------------------------ Global variables
advanced0=999
advanced1=999
band=[-1,600,160,80,60,40,30,20,17,15,12,10,6,4,2,0]
bandmap=[]
bm={}
btune0=999
encal0=999
f0=DoubleVar()
ftx=DoubleVar()
ftx0=0.
ft=[]
fileopened=""
fmid=0.0
fmid0=0.0
font1='Helvetica'
hopping0=99
iband=IntVar()
iband0=0
idle=IntVar()
idle0=999
ierr=0
inbad0=999
ipctx=IntVar()
ndgain=IntVar()
isec0=0
isync=1
itx0=0
loopall=0
modpixmap0=0
mrudir=os.getcwd()
ndbm0=-999
ncal0=999
ncall=0
ndebug=IntVar()
ndecoding0=999
nin0=0
nout0=0
nred=0
ntune0=999
newdat=1
newspec=1
no_beep=IntVar()
npal=IntVar()
npal.set(2)
nparam=0
ntrminutes=IntVar()
ntrminutes0=0
nsave=IntVar()
nscroll=0
nsec0=0
nspeed0=IntVar()
ntr0=0
ntxfirst=IntVar()
NX=500
NY=160
outbad0=999
param20=""
sf0=StringVar()
sftx=StringVar()
start_idle=IntVar()
startup=1
t0=""
timer1=0
txmsg=StringVar()
txmute=IntVar()
txmute0=999
upload0=999
nreject=0
gain=1.0
phdeg=0.0

a=array.array('h')
im=Image.new('P',(NX,NY))
draw=ImageDraw.Draw(im)
im.putpalette(Colormap2Palette(colormapLinrad),"RGB")
pim=ImageTk.PhotoImage(im)
receiving=0
scale0=1.0
offset0=0.0
s0=0.0
c0=0.0
slabel="MinSync  "
transmitting=0
tw=[]
fw=[] # band labels for spectrum display
upload=IntVar()
balloon=Pmw.Balloon(root)

g.appdir=appdir
g.cmap="Linrad"
g.cmap0="Linrad"
g.ndevin=IntVar()
g.ndevout=IntVar()
g.DevinName=StringVar()
g.DevoutName=StringVar()

pwrlist=(-30,-27,-23,-20,-17,-13,-10,-7,-3,   \
         0,3,7,10,13,17,20,23,27,30,33,37,40,43,47,50,53,57,60)
freq0=[0,0.5024,1.8366,3.5926,5.2872,7.0386,10.1387,14.0956,18.1046,\
       21.0946,24.9246,28.1246,50.2930,70.0286,144.4890,0.1360]
freqtx=[0,0.5024,1.8366,3.5926,5.2872,7.0386,10.1387,14.0956,18.1046,\
       21.0946,24.9246,28.1246,50.2930,70.0301,144.4890,0.1375]

for i in range(15):
    freqtx[i]=freq0[i]+0.001500

socktimeout = 20
socket.setdefaulttimeout(socktimeout)

def pal_gray0():
    g.cmap="gray0"
    im.putpalette(Colormap2Palette(colormapgray0),"RGB")
def pal_gray1():
    g.cmap="gray1"
    im.putpalette(Colormap2Palette(colormapgray1),"RGB")
def pal_linrad():
    g.cmap="Linrad"
    im.putpalette(Colormap2Palette(colormapLinrad),"RGB")
def pal_blue():
    g.cmap="blue"
    im.putpalette(Colormap2Palette(colormapblue),"RGB")
def pal_Hot():
    g.cmap="Hot"
    im.putpalette(Colormap2Palette(colormapHot),"RGB")
def pal_AFMHot():
    g.cmap="AFMHot"
    im.putpalette(Colormap2Palette(colormapAFMHot),"RGB")

#------------------------------------------------------ quit
def quit(event=NONE):
    root.destroy()

#------------------------------------------------------ openfile
def openfile(event=NONE):
    global mrudir,fileopened,nopen,tw
    nopen=1                         #Work-around for "click feedthrough" bug
    upload.set(0)
    try:
        os.chdir(mrudir)
    except:
        pass
    fname=askopenfilename(filetypes=[("Wave files","*.wav *.WAV")])
    if fname:
        w.getfile(fname,len(fname))
        mrudir=os.path.dirname(fname)
        fileopened=os.path.basename(fname)
        i1=fileopened.find('.')
        t=fileopened[i1-4:i1]
        t=t[0:2] + ':' + t[2:4]
        n=len(tw)
        if n>12: tw=tw[:n-1]
        tw=[t,] + tw
    os.chdir(appdir)
    idle.set(1)

#------------------------------------------------------ stop_loopall
def stop_loopall(event=NONE):
    global loopall
    loopall=0
    
#------------------------------------------------------ opennext
def opennext(event=NONE):
    global ncall,fileopened,loopall,mrudir,tw,ndecoding0

    if int(w.acom1.ndecoding) != 0:
        return
    upload.set(0)
    if fileopened=="" and ncall==0:
        openfile()
        ncall=1
    else:
# Make a list of *.wav files in mrudir
        la=os.listdir(mrudir)
        la.sort()
        lb=[]
        for i in range(len(la)):
            j=la[i].find(".wav") + la[i].find(".WAV")
            if j>0: lb.append(la[i])
        for i in range(len(lb)):
            if lb[i]==fileopened:
                break
        if i<len(lb)-1:
            fname=mrudir+"/"+lb[i+1]
            w.getfile(fname,len(fname))
            mrudir=os.path.dirname(fname)
            fileopened=os.path.basename(fname)
            i1=fileopened.find('.')
            t=fileopened[i1-4:i1]
            t=t[0:2] + ':' + t[2:4]
            n=len(tw)
            if n>12: tw=tw[:n-1]
            tw=[t,] + tw
        else:
            t="No more *.wav files in this directory."
            result=tkMessageBox.showwarning(message=t)
            ncall=0
            loopall=0
            
#------------------------------------------------------ decodeall
def decodeall(event=NONE):
    global loopall
    loopall=1
    opennext()

#------------------------------------------------------ hopping1
def hopping1(event=NONE):
    t=''
    if root_geom.find('+')>=0:
        t=root_geom[root_geom.index('+'):]
    hopping.hopping2(t)

#------------------------------------------------------ options1
def options1(event=NONE):
    t=''
    if root_geom.find('+')>=0:
        t=root_geom[root_geom.index('+'):]
    options.options2(t)

#------------------------------------------------------ advanced1
def advanced1(event=NONE):
    t=""
    if root_geom.find("+")>=0:
        t=root_geom[root_geom.index("+"):]
    advanced.advanced2(t)

#------------------------------------------------------ iq1
def iq1(event=NONE):
    t=""
    if root_geom.find("+")>=0:
        t=root_geom[root_geom.index("+"):]
    iq.iq2(t)

#------------------------------------------------------ stub
def stub(event=NONE):
    MsgBox("Sorry, this function is not yet implemented.")

#------------------------------------------------------ MsgBox
def MsgBox(t):
    result=tkMessageBox.showwarning(message=t)

#------------------------------------------------------ msgpos
def msgpos():
    g=root_geom[root_geom.index("+"):]
    t=g[1:]
    x=int(t[:t.index("+")])          # + 70
    y=int(t[t.index("+")+1:])        # + 70
    return "+%d+%d" % (x,y)    

#------------------------------------------------------ about
def about(event=NONE):
    global Version
    about=Toplevel(root)
    about.geometry(msgpos())
    if g.Win32: about.iconbitmap("wsjt.ico")
    t="WSPR Version " + Version + ", by K1JT"
    Label(about,text=t,font=(font1,16)).pack(padx=20,pady=5)
    t="""
WSPR (pronounced "whisper") stands for "Weak Signal
Propagation Reporter".  The program generates and decodes
a digital soundcard mode optimized for beacon-like
transmissions on the LF, MF, and HF bands.

Copyright (c) 2008-2011 by Joseph H. Taylor, Jr., K1JT, with
contributions from VA3DB, G4KLA, W1BW, and 4X6IZ.  WSPR is
Open Source software, licensed under the GNU General Public
License (GPL).  Source code and programming information may
be found at http://developer.berlios.de/projects/wsjt/.
"""
    Label(about,text=t,justify=LEFT).pack(padx=20)
    t="Revision date: " + \
      "$Date: 2010-09-17 13:03:38 -0400 (Fri, 17 Sep 2010) $"[7:-1]
    Label(about,text=t,justify=LEFT).pack(padx=20)
    about.focus_set()

#------------------------------------------------------ 
def help(event=NONE):
    about=Toplevel(root)
    about.geometry(msgpos())
    if g.Win32: about.iconbitmap("wsjt.ico")
    t="Basic Operating Instructions"
    Label(about,text=t,font=(font1,14)).pack(padx=20,pady=5)
    t="""
1. Open the Setup | Station Parameters screen and enter
   your callsign and grid locator 6 characters).  Select
   desired devices for Audio In and Audio Out, and your
   power level in dBm.
   
2. Select your PTT method (CAT control, DTR, or RTS).  If
   you choose DTR or RTS, select a PTT port.  If T/R
   switching or frequency setting will be done by CAT
   control, select a CAT port and be sure that "Enable CAT"
   is checked.  You will need to enter a Rig number and
   correct parameters for the serial connection.

3. Select the desired band from the Band menu and if
   necessary correct your USB dial frequency on the main
   screen.  Select a Tx frequency by double-clicking
   somewhere on the waterfall display.

4. Select a desired 'Tx fraction' using the large slider. Zero
   percent means Rx only; 100% means Tx only.
   
5. Be sure that your computer clock is correct to +/- 1 s.
   Many people like to use an automatic internet-based
   clock-setting utility.

6. WSPR will begin a Tx or Rx sequence at the start of each
   even-numbered minute.  The waterfall will update and
   decoding will take place at the end of each Rx sequence.
   During reception, you can adjust the Rx noise level to get
   something close to 0 dB.  Use the operating system's audio
   mixer control or change your receiver's output level.
"""
    Label(about,text=t,justify=LEFT).pack(padx=20)
    about.focus_set()

#------------------------------------------------------ usersguide
def usersguide(event=NONE):
    url='http://physics.princeton.edu/pulsar/K1JT/WSPR_4.0_User.pdf'
    thread.start_new_thread(browser,(url,))

#------------------------------------------------------ fmtguide
def fmtguide(event=NONE):
    url='http://physics.princeton.edu/pulsar/K1JT/FMT_User.pdf'
    thread.start_new_thread(browser,(url,))

#------------------------------------------------------ wsprnet
def wsprnet(event=NONE):
    url='http://wsprnet.org/'
    thread.start_new_thread(browser,(url,))

#------------------------------------------------------ homepage
def homepage(event=NONE):
    url='http://physics.princeton.edu/pulsar/K1JT/'
    thread.start_new_thread(browser,(url,))

#------------------------------------------------------- browser
def browser(url):
    webbrowser.open(url)

#------------------------------------------------------ erase
def erase(event=NONE):
    global bandmap,bm
    text.configure(state=NORMAL)
    text.delete('1.0',END)
    text.configure(state=DISABLED)
    text1.configure(state=NORMAL)
    text1.delete('1.0',END)
    text1.configure(state=DISABLED)
    bandmap=[]
    bm={}

#------------------------------------------------------ tune
def tune(event=NONE):
    idle.set(1)
    w.acom1.ntune=1
    btune.configure(bg='yellow')
#    balloon.configure(state='none')

#------------------------------------------------------ txnext
def txnext(event=NONE):
    if ipctx.get()>0:
        w.acom1.ntxnext=1
        btxnext.configure(bg="green")

###------------------------------------------------------ stoptx
##def stoptx(event=NONE):
##    w.acom1.nstoptx=1
##    w.acom1.ntxnext=0

#----------------------------------------------------- df_readout
# Readout of graphical cursor location
def df_readout(event):
    global fmid,nred
    nred=10
    df=12000/8192.0
    if ntrminutes.get()==15: df=12000/65536.0
    nhz=1000000*fmid + (80.0-event.y)*df + 2
    nhz=int(nhz%1000)
    t="%3d Hz" % nhz
    lab02.configure(text=t,bg='red')

#----------------------------------------------------- set_tx_freq
def set_tx_freq(event):
    global fmid
    df=12000/8192.0
    if ntrminutes.get()==15: df=12000/65536.0
    nftx=int(1000000.0*fmid + (80.0-event.y)*df) + 2
    fmhz=0.000001*nftx
    t="Please confirm setting Tx frequency to " + "%.06f MHz" % fmhz
    result=tkMessageBox.askyesno(message=t)
    if result:
        ftx.set(0.000001*nftx)
        sftx.set('%.06f' % ftx.get())

#-------------------------------------------------------- draw_axis
def draw_axis():
    global fmid
    c.delete(ALL)
    if ntrminutes.get()==15: df=12000.0/65536.0
    nfmid=int(1.0e6*fmid + 0.5)%1000
# Draw and label tick marks
    if ntrminutes.get()==2:
        df=12000.0/8192.0
        for iy in range(-120,120,10):
            j=80 - iy/df
            i1=7
            if (iy%50)==0:
                i1=12
                if (iy%100)==0: i1=15
                n=nfmid+iy
                if n<0: n=n+1000
                c.create_text(27,j,text=str(n))
            c.create_line(0,j,i1,j,fill='black')
        iy=1000000.0*(ftx.get()-f0.get()) - 1500
        if abs(iy)<=100:
            j=80 - iy/df
            c.create_line(0,j,13,j,fill='red',width=3)            

    if ntrminutes.get()==15:
        df=12000.0/65536.0
        for iy in range(-15,15):
            j=82 - iy/df
            i1=7
            n=nfmid+iy
            if (n%5)==0:
                i1=12
                if (n%10)==0: i1=15
                if n<0: n=n+1000
                c.create_text(27,j,text=str(n))
            c.create_line(0,j,i1,j,fill='black')

        iy=1000000.0*(ftx.get()-f0.get()) - 1612.5
        if abs(iy)<=13:
            j=80 - iy/df
            c.create_line(0,j,13,j,fill='red',width=3)

#------------------------------------------------------ del_all
def del_all():
    fname=appdir+'/ALL_WSPR.TXT'
    try:
        os.remove(fname)
    except:
        pass

#------------------------------------------------------ delwav
def delwav():
    t="Are you sure you want to delete\nall *.WAV files in the Save directory?"
    result=tkMessageBox.askyesno(message=t)
    if result:
# Make a list of *.wav files in Save
        la=dircache.listdir(appdir+'/save')
        lb=[]
        for i in range(len(la)):
            j=la[i].find(".wav") + la[i].find(".WAV")
            if j>0: lb.append(la[i])
# Now delete them all.
        for i in range(len(lb)):
            fname=appdir+'/save/'+lb[i]
            os.remove(fname)

#--------------------------------------------------- rx_volume
def rx_volume():
    for path in string.split(os.environ["PATH"], os.pathsep):
        file = os.path.join(path, "sndvol32") + ".exe"
        try:
            return os.spawnv(os.P_NOWAIT, file, (file,) + (" -r",))
        except os.error:
            pass
    raise os.error, "Cannot find "+file

#--------------------------------------------------- tx_volume
def tx_volume():
    for path in string.split(os.environ["PATH"], os.pathsep):
        file = os.path.join(path, "sndvol32") + ".exe"
        try:
            return os.spawnv(os.P_NOWAIT, file, (file,))
        except os.error:
            pass
    raise os.error, "Cannot find "+file

#------------------------------------------------------ get_decoded
def get_decoded():
    global bandmap,bm,newdat,loopall
    
# Get lines from decoded.txt and parse each into an associative array
    try:
        f=open(appdir+'/decoded.txt',mode='r')
        decodes = []
        for line in f:
            fields = line.split()
            if len(fields) < 10: continue
            msg = fields[6:-3]
            d = {}
            d['date'] = fields[0]
            d['time'] = fields[1]
            d['sync'] = fields[2]
            d['snr'] = fields[3]
            d['dt'] = fields[4]
            d['freq'] = fields[5]
            d['msg'] = msg
            d['drift'] = fields[-3]
            d['cycles'] = fields[-2]
            d['ii'] = fields[-1]

# Determine message type
            d['type1'] = True
            d['type2'] = False
            d['type3'] = False
            if len(msg) != 3 or len(msg[1]) != 4 or len(msg[0]) < 3 or \
                len(msg[0]) > 6 or not msg[2].isdigit():
                d['type1'] = False
            else:
                dbm = int(msg[2])
                if dbm < 0 or dbm > 60:
                    d['type1'] = False
                n=dbm%10
                if n!=0 and n!=3 and n!=7:
                    d['type1'] = False
            if not d['type1']:
                if len(msg)==2:
                    d['type2']=True
                else:
                    d['type3']=True
# Get callsign
            callsign = d['msg'][0]
            if callsign[0]=='<':
                n=callsign.find('>')
                callsign=callsign[1:n]
            d['call'] = callsign
            decodes.append(d)
        f.close()
    except:
        decodes = []

    if len(decodes) > 0:
#  Write data to text box; append freqs and calls to bandmap.
        text.configure(state=NORMAL)
        nseq=0
        nfmid=int(1.0e6*fmid)%1000
        for d in decodes:
            text.insert(END, "%4s %3s %4s %10s %2s %s\n" % \
                (d['time'],d['snr'],d['dt'],d['freq'],d['drift'],' '.join(d['msg'])))
            try:
                callsign=d['call']
                tmin=60*int(d['time'][0:2]) + int(d['time'][2:4])
                ndf=int(d['freq'][-3:])
                bandmap.append((ndf,callsign,tmin))
            except:
                pass
        text.configure(state=DISABLED)
        text.see(END)

# Erase the bm{} dictionary, then repopulate it from "bandmap".
# Most recent info for each callsign should be saved.
    bm={}
    iz=len(bandmap)
    for i in range(iz):
        bm[bandmap[i][1]]=(bandmap[i][0],bandmap[i][2])

# Erase bandmap entirely
    bandmap=[]
# Repopulate "bandmap" from "bm", which should not contain dupes.
    for callsign,ft in bm.iteritems():
        if callsign!='...':
            ndf,tdecoded=ft
            tmin=int((time.time()%86400)/60)
            tdiff=tmin-tdecoded
            if tdiff<0: tdiff=tdiff+1440
# Insert info in "bandmap" only if age is less than one hour
            if w.acom1.ndiskdat==1: tdiff=2
            if tdiff < 60:                        #60 minutes 
                bandmap.append((ndf,callsign,tdecoded))
    
# Once more, erase the bm{} dictionary, then repopulate it from "bandmap"
    bm={}
    iz=len(bandmap)
    for i in range(iz):
        bm[bandmap[i][1]]=(bandmap[i][0],bandmap[i][2])

#  Sort bandmap in reverse frequency order, then display it
    bandmap.sort()
    bandmap.reverse()
    text1.configure(state=NORMAL)
    text1.delete('1.0',END)
    for i in range(iz):
        t="%4d" % (bandmap[i][0],) + " " + bandmap[i][1]
        nage=int((tmin - bandmap[i][2])/15)
        if nage<0: nage=nage+96
        attr='age0'
        if nage==1: attr='age1'
        if nage==2: attr='age2'
        if nage>=3: attr='age3'
        if w.acom1.ndiskdat==1: attr='age0'
        text1.insert(END,t+"\n",attr)
    text1.configure(state=DISABLED)
    text1.see(END)

    if upload.get():
        #Dispatch autologger thread.
        thread.start_new_thread(autolog, (decodes,))

    if loopall: opennext()

#------------------------------------------------------ autologger
def autolog(decodes):
    # Random delay of up to 20 seconds to spread load out on server --W1BW
    time.sleep(random.random() * 20.0)
    try:
        # This code originally by W6CQZ ... modified by W1BW
        # TODO:  Cache entries for later uploading if net is down.
        # TODO:  (Maybe??) Allow for stations wishing to collect spot data but
        #       only upload in batch form vs real-time.
        # Any spots to upload?
        if len(decodes) > 0:
            for d in decodes:
                # now to format as a string to use for autologger upload using urlencode
                # so we get a string formatted for http get/put operations:
                m=d['msg']
                tcall=m[0]
                if d['type2']:
                    tgrid=''
                    dbm=m[1]
                else:
                    tgrid=m[1]
                    dbm=m[2]
                if tcall[0]=='<':
                    n=tcall.find('>')
                    tcall=tcall[1:n]
                if tcall=='...': continue
                dfreq=float(d['freq'])-w.acom1.f0b-0.001500
                if abs(dfreq)>0.0001 and ntrminutes.get()==2:
                    print 'Frequency changed, no upload of spots'
                    continue
                reportparams = urllib.urlencode({'function': 'wspr',
                                                 'rcall': options.MyCall.get(),
                                                 'rgrid': options.MyGrid.get(),
                                                 'rqrg': str(f0.get()),
                                                 'date': d['date'],
                                                 'time': d['time'],
                                                 'sig': d['snr'],
                                                 'dt': d['dt'],
                                                 'tqrg': d['freq'],
                                                 'drift': d['drift'],
                                                 'tcall': tcall,
                                                 'tgrid': tgrid,
                                                 'dbm': dbm,
                                                 'version': Version})
                # reportparams now contains a properly formed http request string for
                # the agreed upon format between W6CQZ and N8FQ.
                # any other data collection point can be added as desired if it conforms
                # to the 'standard format' defined above.
                # The following opens a url and passes the reception report to the database
                # insertion handler for W6CQZ:
                #                urlf = urllib.urlopen("http://jt65.w6cqz.org/rbc.php?%s" % reportparams)
                # The following opens a url and passes the reception report to the
                # database insertion handler from W1BW:
                urlf = urllib.urlopen("http://wsprnet.org/post?%s" \
                                  % reportparams)
                reply = urlf.readlines()
                urlf.close()
        else:
            # No spots to report, so upload status message instead. --W1BW
            reportparams = urllib.urlencode({'function': 'wsprstat',
                                             'rcall': options.MyCall.get(),
                                             'rgrid': options.MyGrid.get(),
                                             'rqrg': str(fmid),
                                             'tpct': str(ipctx.get()), 
                                             'tqrg': sftx.get(),
                                             'dbm': str(options.dBm.get()),
                                             'version': Version})
            urlf = urllib.urlopen("http://wsprnet.org/post?%s" \
                                  % reportparams)
            reply = urlf.readlines()
            urlf.close()
    except:
        t=" UTC: attempted access to WSPRnet failed."
        if not no_beep.get(): t=t + "\a"
        print time.asctime(time.gmtime()) + t

#------------------------------------------------------ put_params
def put_params(param3=NONE):
    global param20

##    try:
##        w.acom1.f0=f0.get()
##        w.acom1.ftx=ftx.get()
##    except:
##        pass
    w.acom1.callsign=(options.MyCall.get().strip().upper()+'            ')[:12]
    w.acom1.grid=(options.MyGrid.get().strip().upper()+'    ')[:4]
    w.acom1.grid6=(options.MyGrid.get().strip().upper()+'      ')[:6]
    w.acom1.ctxmsg=(txmsg.get().strip().upper()+'                      ')[:22]

    # numeric port ==> COM%d, else string of device.  --W1BW
    port = options.PttPort.get()
    if port=='None': port='0'
    if port[:3]=='COM': port=port[3:]
    if port.isdigit():
        w.acom1.nport = int(port)
        port = "COM%d" % (int(port))
    else:
        w.acom1.nport = 0
    w.acom1.pttport = (port + 80*' ')[:80]

    try:
        dbm=int(options.dBm.get())
    except:
        dbm=37
    i1=options.MyCall.get().find('/')
    if dbm<0 and (i1>0 or advanced.igrid6.get()):
        MsgBox("Negative dBm values are permitted\n only for Type 1 messages.")
        dbm=0
        options.dBm.set(0)
    mindiff=9999
    for i in range(len(pwrlist)):
        if abs(dbm-pwrlist[i])<mindiff:
            mindiff=abs(dbm-pwrlist[i])
            ibest=i
    dbm=pwrlist[ibest]
    options.dBm.set(dbm)
    w.acom1.ndbm=dbm
        
    w.acom1.ntxfirst=ntxfirst.get()
    w.acom1.nsave=nsave.get()
    try:
        w.acom1.nbfo=advanced.bfofreq.get()
    except:
        w.acom1.nbfo=1500
    try:
        w.acom1.idint=advanced.idint.get()
    except:
        w.acom1.idint=0
    w.acom1.igrid6=advanced.igrid6.get()
    w.acom1.iqmode=iq.iqmode.get()
    w.acom1.iqrx=iq.iqrx.get()
    w.acom1.iqrxapp=iq.iqrxapp.get()
    w.acom1.iqrxadj=iq.iqrxadj.get()
    w.acom1.iqtx=iq.iqtx.get()
    w.acom1.ntxdb=advanced.isc1.get()
    bal=iq.isc2.get() + 0.02*iq.isc2a.get()
    w.acom1.txbal=bal
    pha=iq.isc3.get() + 0.02*iq.isc3a.get()
    w.acom1.txpha=pha
    try:
        w.acom1.nfiq=iq.fiq.get()
    except:
        w.acom1.nfiq=0
    w.acom1.ndevin=g.ndevin.get()
    w.acom1.ndevout=g.ndevout.get()
    w.acom1.nbaud=options.serial_rate.get()
    w.acom1.ndatabits=options.databits.get()
    w.acom1.nstopbits=options.stopbits.get()
    w.acom1.chs=(options.serial_handshake.get() + \
                 '                                        ')[:40]
    w.acom1.catport=(options.CatPort.get()+'            ')[:12]
    try:
        w.acom1.nrig=options.rignum.get()
    except:
        pass

#------------------------------------------------------ update
# the routine will be invoked ~5 times per second
def update():
    global root_geom,isec0,im,pim,ndbm0,nsec0,a,ftx0,nin0,nout0, \
        receiving,transmitting,newdat,nscroll,newspec,scale0,offset0, \
        modpixmap0,tw,s0,c0,fmid,fmid0,loopall,ntr0,txmsg,iband0, \
        bandmap,bm,t0,nreject,gain,phdeg,ierr,itx0,timer1,ndecoding0, \
        hopping0,ntune0,startup,nred,ntrminutes0

    tsec=time.time()
    utc=time.gmtime(tsec)
    nsec=int(tsec)
    nsec0=nsec

# enable/disable the Band Hop check box
    if ntrminutes.get()==2:
        if hopping.hoppingconfigured.get()==1:
            if hopping0!=1:
                hopping0=1
                bhopping.configure(state=NORMAL)
        else:
            if hopping0!=2:
                hopping0=2
                bhopping.configure(state=DISABLED)
    else:
        hopping.hopping.set(0)
        bhopping.configure(state=DISABLED)
        hopping0=2
        
# implement band happing if it was selected
    hopped=0
    if not idle.get() and ntrminutes.get()==2:
        if hopping.hopping.get()==1:
            w.acom1.nfhopping=1        
            if w.acom1.nfhopok or startup:
                w.acom1.nfhopok=0
                startup=0
                b=-1
                if hopping.coord_bands.get()==1:
                    ns=nsec % 86400
                    ns1=ns % (10*120)
                    b=ns1/120 + 3
                    if b==12: b=2
                    if hopping.hoppingflag[b].get()==0: b=-1
                if b<0:                
                    found=False
                    while not found:
                        b = random.randint(1,len(hopping.bandlabels)-1)
                        if hopping.hoppingflag[b].get()!=0:
                            found=True
                ipctx.set(hopping.hoppingpctx[b].get())
                if b!=iband.get(): hopped=1
                iband.set(b)

        else:
            w.acom1.nfhopping=0
            ns=nsec % 86400
            ns1=ns % (10*120)
            b=ns1/120 + 3
            if b==12: b=2
            if iband.get()==b and random.randint(1,2)==1 and ipctx.get()>0:
                w.acom1.ntxnext=1

    try:
        f0.set(float(sf0.get()))
        ftx.set(float(sftx.get()))
    except:
        pass

    isec=utc[5]
    trmin=ntrminutes.get()
    twait=trmin - (tsec % trmin)

    if iband.get()!=iband0 or advanced.fset.get():
        advanced.fset.set(0)
        f0.set(freq0[iband.get()])
        t="%.6f" % (f0.get(),)
        sf0.set(t)
        ftx.set(freqtx[iband.get()])
        t="%.6f" % (ftx.get(),)
        sftx.set(t)
        if options.cat_enable.get():
            if advanced.encal.get():
                nHz=int(advanced.Acal.get() + \
                    f0.get()*(1000000.0 + advanced.Bcal.get()) + 0.5)
            else:
                nHz=int(1000000.0*f0.get() + 0.5)
            if options.rignum.get()==2509 or options.rignum.get()==2511:
                nHzLO=nHz - iq.fiq.get()
                cmd="rigctl -m %d -r %s F %d" % \
                     (options.rignum.get(),options.CatPort.get(),nHzLO)
            elif options.rignum.get()==1901:
                cmd="rigctl -m 1901 -r localhost F %d" % (nHz,)
            else:
                cmd="rigctl -m %d -r %s -s %d -C data_bits=%s -C stop_bits=%s -C serial_handshake=%s F %d" % \
                     (options.rignum.get(),options.CatPort.get(), \
                      options.serial_rate.get(),options.databits.get(), \
                      options.stopbits.get(),options.serial_handshake.get(), nHz)
            ierr=os.system(cmd)
            if ierr==0:
                ierr2=0
                bandmap=[]
                bm={}
                text1.configure(state=NORMAL)
                text1.delete('1.0',END)
                text1.configure(state=DISABLED)
                iband0=iband.get()
                f=open(appdir+'/fmt.ini',mode='w')
                f.write(cmd+'\n')
                f.write(str(g.ndevin.get())+'\n')
                f.write(options.MyCall.get()+'\n')
                f.write(options.MyGrid.get()+'\n')
                f.close()

                cmd2=''
                if os.path.exists('.\user_hardware.bat') or \
                   os.path.exists('.\user_hardware.cmd') or \
                   os.path.exists('.\user_hardware.exe'):
                    cmd2='.\user_hardware ' + str(band[iband0])
                elif os.path.exists('./user_hardware'):
                    cmd2='./user_hardware ' + str(band[iband0])
                if cmd2!='':
                    try:
                        ierr2=os.system(cmd2)
                    except:
                        ierr2=-1
                    if ierr2!=0:
                        print 'Execution of "'+cmd2+'" failed.'
                        MsgBox('Execution of "'+cmd2+'" failed.\nEntering Idle mode.')
            else:
                print 'Error attempting to set rig frequency.\a'
                print cmd + '\a'
                iband.set(iband0)
                f0.set(freq0[iband.get()])
                t="%.6f" % (f0.get(),)
                sf0.set(t)
                ftx.set(freqtx[iband.get()])
                t="%.6f" % (ftx.get(),)
                sftx.set(t)
            if ierr==0 and ierr2==0 and w.acom1.nfhopping==1 and hopped==1 \
                   and hopping.tuneupflag[iband.get()].get(): w.acom1.ntune=-3
        else:
            iband0=iband.get()
        iq.ib.set(iband.get())
        iq.newband()

    freq0[iband.get()]=f0.get()
    freqtx[iband.get()]=ftx.get()
    w.acom1.iband=iband.get()

    try:
        w.acom1.f0=f0.get()
        w.acom1.ftx=ftx.get()
    except:
        pass

    newsecond=0					# =1 if a new second
    if isec != isec0:                           #Do once per second
# this code block is executed once per second
	newsecond=1
        t=time.strftime('%Y %b %d\n%H:%M:%S',utc)
        ldate.configure(text=t)
        root_geom=root.geometry()
        utchours=utc[3]+utc[4]/60.0 + utc[5]/3600.0
        try:
            if options.dBm.get()!=ndbm0:
                ndbm0=options.dBm.get()
                options.dbm_balloon()
        except:
            pass

        put_params()
        nndf=int(1000000.0*(ftx.get()-f0.get()) + 0.5) - 1500
        gain=w.acom1.gain
        phdeg=57.2957795*w.acom1.phase
        nreject=int(w.acom1.reject)

        if ntrminutes.get()!=ntrminutes0:
            if ntrminutes.get()==2:
                msg4.configure(text='WSPR-2',bg='green')
                setupmenu.entryconfig(2,state=NORMAL)
                setupmenu.entryconfig(3,state=NORMAL)
            elif ntrminutes.get()==15:
                msg4.configure(text='WSPR-15',bg='#00ffff')
                setupmenu.entryconfig(2,state=DISABLED)
                setupmenu.entryconfig(3,state=DISABLED)
            ntrminutes0=ntrminutes.get()

# this code block is executed ~5 times per second
# NB: the digital gain control "ndgain" presently has cosmetic effect only.
    ndb=int(w.acom1.xdb1-41.0+ndgain.get())
    if ndb<-30: ndb=-30
    dbave=w.acom1.xdb1
    if iq.iqmode.get():
        t='Bal: %6.4f  Pha: %6.1f      >%3d dB' % (gain,phdeg,nreject)
        iq.lab1.configure(text=t)
        ndb2=int(w.acom1.xdb2-41.0)
        if ndb2<-30: ndb2=-30
        dbave=0.5*(w.acom1.xdb1 + w.acom1.xdb2)
        t='Rx Noise: %3d %3d  dB' % (ndb,ndb2)
    else:
        t='Rx Noise: %3d  dB' % (ndb,)
# update noise display at lower left of screen
    bg='gray85'
    r=SUNKEN
    smcolor="green"
    if w.acom1.receiving==0:
        t=''
        r=FLAT
        
    if isec!=isec0:
        msg1.configure(text=t,relief=r)
        isec0=isec
    
    dbave=dbave + ndgain.get()
    if not receiving: dbave=0
    sm.updateProgress(newValue=dbave,newColor=smcolor)
    
    if nred>0:
        nred=nred-1
        if nred==0: lab02.configure(text="",bg='gray85')

# If T/R status has changed, get new info
    ntr=int(w.acom1.ntr)
    itx=w.acom1.transmitting
    if ntr!=ntr0 or itx!=itx0:
        ntr0=ntr
        itx0=int(itx)
        if ntr==-1 or itx==1:
            transmitting=1
            receiving=0
        elif ntr==0:
            transmitting=0
            receiving=0
        else:
            transmitting=0
            receiving=1
            n=len(tw)
            if n>12: tw=tw[:n-1]
            rxtime=g.ftnstr(w.acom1.rxtime)
            rxtime=rxtime[:2] + ':' + rxtime[2:]
            tw=[rxtime,] + tw
 
            global fw
            if n>12: fw=fw[:n-1]
            fw=[hopping.bandlabels[ iband.get()][:-2],] + fw
        if receiving:
            filemenu.entryconfig(0,state=DISABLED)
            filemenu.entryconfig(1,state=DISABLED)
            filemenu.entryconfig(2,state=DISABLED)
        else:
            filemenu.entryconfig(0,state=NORMAL)
            filemenu.entryconfig(1,state=NORMAL)
            filemenu.entryconfig(2,state=NORMAL)
        if transmitting:
            btxnext.configure(bg="gray85")
            for i in range(15):
                bandmenu.entryconfig(i,state=DISABLED)
        else:
            for i in range(15):
                bandmenu.entryconfig(i,state=NORMAL)

# update the receiving status at the lower right of screen
    bgcolor='gray85'
    t='Waiting to start'
    bgcolor='pink'
    if transmitting:
        t='Txing: '+g.ftnstr(w.acom1.sending)
        bgcolor='yellow'
    if receiving:
        t='Receiving'
        bgcolor='green'
    if t!=t0:			# dont draw unless changed
        msg6.configure(text=t,bg=bgcolor)
        t0=t

# tend to percent scale
    ntune=int(w.acom1.ntune)
    if ntune!=ntune0:
        ntune0=ntune
	if ntune==0:
	    btune.configure(bg='gray85')
	    pctscale.configure(state=NORMAL)
	else:
	    pctscale.configure(state=DISABLED)

# set idle switch
    global ncal0
    ncal=w.acom1.ncal
    if ncal!=ncal0:
    	ncal0=ncal
	if ncal==0:
	    advanced.bmeas.configure(bg='gray85')
	else:
	    idle.set(1)

    if ierr==0 and txmute.get()==0:
      w.acom1.pctx=ipctx.get()
    else:
      w.acom1.pctx=0

# if mute is pressed turn TxNext gray and mute button red
    global txmute0
    if txmute.get()!=txmute0:
    	txmute0=txmute.get()
	if txmute0:
	    w.acom1.pctx=0
	    w.acom1.ntxnext=0
	    bmute.configure(bg='red')
	    btxnext.configure(state=DISABLED)
	    btxnext.configure(bg='gray85')
	else:
	    bmute.configure(bg='gray85')
	    btxnext.configure(state=NORMAL)

    w.acom1.idle=idle.get()

# make idle button yellow if checked
    global idle0
    if idle0!=idle.get():
    	idle0=idle.get()
	if idle0==0:
	    bidle.configure(bg='gray85')
	else:
	    bidle.configure(bg='yellow')

    global btune0
    if w.acom1.transmitting or w.acom1.receiving or options.outbad.get():
        if btune0!=1:
	    btune0=1
	    btune.configure(state=DISABLED)
    else:
        if btune0!=2:
	    btune0=2
	    btune.configure(state=NORMAL)

    global advanced0
    if w.acom1.transmitting or w.acom1.receiving or twait < 6.0:
        if advanced0!=1:
	    advanced0=1
	    advanced.bmeas.configure(state=DISABLED)
    else:
        if advanced0!=2:
	    advanced0=2
	    advanced.bmeas.configure(state=NORMAL)

# update the upload spots button color
    global upload0
    if upload.get()==1:
        if upload0!=1:
	    upload0=1
	    bupload.configure(bg='gray85')
    else:
        if upload0!=2:
	    upload0=2
	    bupload.configure(bg='yellow')

# If new decoded text has appeared, display it.
    if w.acom1.ndecdone:
        get_decoded()
        w.acom1.ndecdone=0
#        w.acom1.ndiskdat=0

# Display the waterfall
    try:
        modpixmap=os.stat('pixmap.dat')[8]
        if modpixmap!=modpixmap0:
            f=open('pixmap.dat','rb')
            a=array.array('h')
            a.fromfile(f,NX*NY)
            f.close()
            newdat=1
            modpixmap0=modpixmap
    except:
	newdat=0

    scale=math.pow(10.0,0.003*sc1.get())
    offset=0.3*sc2.get()
    if newdat or scale!= scale0 or offset!=offset0 or g.cmap!=g.cmap0:
	im.putdata(a,scale,offset)              #Compute whole new image
	if newdat:
	    n=len(tw)
	    for i in range(n-1,-1,-1):
		x=465-39*i
		draw.text((x,148),tw[i],fill=253)        #Insert time label
		if i<len(fw):
		    draw.text((x+10,1),fw[i],fill=253)   #Insert band label
			       
	pim=ImageTk.PhotoImage(im)              #Convert Image to PhotoImage
	graph1.delete(ALL)
	graph1.create_image(0,0+2,anchor='nw',image=pim)
	g.ndecphase=2
	newMinute=0
	scale0=scale
	offset0=offset
	g.cmap0=g.cmap
	newdat=0

    s0=sc1.get()
    c0=sc2.get()
    try:
        fmid=f0.get() + 0.001500
        if ntrminutes.get()==15: fmid=f0.get() + 0.0016115
    except:
        pass

    if fmid!=fmid0 or ftx.get()!=ftx0:
        fmid0=fmid
	ftx0=ftx.get()
        draw_axis()
        if ntrminutes.get()==2:
            lftx.configure(validate={'validator':'real',
                'min':f0.get()+0.001500-0.000100,'minstrict':0,
                'max':f0.get()+0.001500+0.000100,'maxstrict':0})
        if ntrminutes.get()==15:
            lftx.configure(validate={'validator':'real',
                'min':f0.get()+0.0016115-0.0000125,'minstrict':0,
                'max':f0.get()+0.0016115+0.0000125,'maxstrict':0})

    w.acom1.ndebug=ndebug.get()

    if options.rignum.get()==2509 or options.rignum.get()==2511:
        options.pttmode.set('CAT')
        options.CatPort.set('USB')

    if options.pttmode.get()=='CAT':
        options.cat_enable.set(1)

    if options.pttmode.get()=='CAT' or options.pttmode.get()=='VOX':
        options.PttPort.set('None')
        options.ptt_port._entryWidget['state']=DISABLED
    else:
        options.ptt_port._entryWidget['state']=NORMAL

    global advanced1
    if options.cat_enable.get():
        options.lrignum._entryWidget['state']=NORMAL
        if options.cat_port.get() != 'USB':
            options.cat_port._entryWidget['state']=NORMAL
            options.cbbaud._entryWidget['state']=NORMAL
            options.cbdata._entryWidget['state']=NORMAL
            options.cbstop._entryWidget['state']=NORMAL
            options.cbhs._entryWidget['state']=NORMAL
        else:
            options.cat_port._entryWidget['state']=DISABLED
            options.cbbaud._entryWidget['state']=DISABLED
            options.cbdata._entryWidget['state']=DISABLED
            options.cbstop._entryWidget['state']=DISABLED
            options.cbhs._entryWidget['state']=DISABLED
	if advanced1!=1:
	    advanced1=1
	    advanced.bsetfreq.configure(state=NORMAL)
	    advanced.breadab.configure(state=NORMAL)
	    advanced.enable_cal.configure(state=NORMAL)
    else:
        options.cat_port._entryWidget['state']=DISABLED
        options.lrignum._entryWidget['state']=DISABLED
        options.cbbaud._entryWidget['state']=DISABLED
        options.cbdata._entryWidget['state']=DISABLED
        options.cbstop._entryWidget['state']=DISABLED
        options.cbhs._entryWidget['state']=DISABLED
	if advanced1!=2:
	    advanced1=2
	    advanced.bsetfreq.configure(state=DISABLED)
	    advanced.breadab.configure(state=DISABLED)
	    advanced.enable_cal.configure(state=DISABLED)
	    advanced.encal.set(0)

    w.acom1.pttmode=(options.pttmode.get().strip()+'   ')[:3]
    w.acom1.ncat=options.cat_enable.get()
    w.acom1.ncoord=hopping.coord_bands.get()
    w.acom1.ntrminutes=ntrminutes.get()
    if(ntrminutes.get() != 2 and hopping.hoppingconfigured.get()==1):
        hopping.hopping.set(0)

    if g.ndevin.get()!= nin0 or g.ndevout.get()!=nout0:
        audio_config()
        nin0=g.ndevin.get()
        nout0=g.ndevout.get()

    global inbad0
    if inbad0!=options.inbad.get():
	inbad0=options.inbad.get()
	if inbad0==0:
	    msg2.configure(text='',bg='gray85')
	else:
	    msg2.configure(text='Invalid audio input device.',bg='red')

    global outbad0
    if outbad0!=options.outbad.get():
	outbad0=options.outbad.get()
	if outbad0==0:
	    msg3.configure(text='',bg='gray85')
	else:
	    msg3.configure(text='Invalid audio output device.',bg='red')

    if ndecoding0!=int(w.acom1.ndecoding):
	ndecoding0=int(w.acom1.ndecoding)
	if ndecoding0:
	    msg5.configure(text='Decoding',bg='#66FFFF',relief=SUNKEN)
	else:
	    msg5.configure(text='',bg='gray85',relief=FLAT)

    global encal0
    if encal0!=advanced.encal.get():
	encal0=advanced.encal.get()
	if encal0:
	    advanced.A_entry.configure(entry_state=NORMAL,label_state=NORMAL)
	    advanced.B_entry.configure(entry_state=NORMAL,label_state=NORMAL)
	else:
	    advanced.A_entry.configure(entry_state=DISABLED,label_state=DISABLED)
	    advanced.B_entry.configure(entry_state=DISABLED,label_state=DISABLED)
  
    timer1=ldate.after(200,update)

#------------------------------------------------------ audio_config
def audio_config():
    inbad,outbad=w.audiodev(g.ndevin.get(),g.ndevout.get())
    options.inbad.set(inbad)
    options.outbad.set(outbad)
    if inbad or outbad:
        w.acom1.ndevsok=0
        options1()
    else:
        w.acom1.ndevsok=1

#------------------------------------------------------ save_params
def save_params():
    f=open(appdir+'/WSPR.INI',mode='w')
    f.write("WSPRGeometry " + root_geom + "\n")
    if options.MyCall.get()=='': options.MyCall.set('##')
    f.write("MyCall " + options.MyCall.get() + "\n")
    if options.MyGrid.get()=='': options.MyGrid.set('##')
    f.write("MyGrid " + options.MyGrid.get() + "\n")
    f.write("CWID " + str(advanced.idint.get()) + "\n")
    f.write("dBm " + str(options.dBm.get()) + "\n")
    f.write("PttPort " + str(options.PttPort.get()) + "\n")
    f.write("CatPort " + str(options.CatPort.get()) + "\n")
    if options.DevinName.get()=='': options.DevinName.set('0')
    f.write("AudioIn "  + options.DevinName.get().replace(" ","#") + "\n")
    if options.DevoutName.get()=='': options.DevoutName.set('2')
    f.write("AudioOut " + options.DevoutName.get().replace(" ","#") + "\n")
    f.write("BFOfreq " + str(advanced.bfofreq.get()) + "\n")
    f.write("PTTmode " + options.pttmode.get() + "\n")
    f.write("CATenable " + str(options.cat_enable.get()) + "\n")
    f.write("Acal " + str(advanced.Acal.get()) + "\n")
    f.write("Bcal " + str(advanced.Bcal.get()) + "\n")
    f.write("CalEnable " + str(advanced.encal.get()) + "\n")
    f.write("IQmode " + str(iq.iqmode.get()) + "\n")
    f.write("IQrx " + str(iq.iqrx.get()) + "\n")
    f.write("IQtx " + str(iq.iqtx.get()) + "\n")
    f.write("FIQ " + str(iq.fiq.get()) + "\n")
    f.write("Ntxdb " + str(advanced.isc1.get()) + "\n")
    f.write("SerialRate " + str(options.serial_rate.get()) + "\n")
    f.write("DataBits " + str(options.databits.get()) + "\n")
    f.write("StopBits " + str(options.stopbits.get()) + "\n")
    f.write("Handshake " + options.serial_handshake.get().replace(" ","#")  + "\n")
    t=str(options.rig.get().replace(" ","#"))
    f.write("Rig " + str(t.replace("\t","#"))[:46] + "\n")
    f.write("Nsave " + str(nsave.get()) + "\n")
    f.write("TRminutes " + str(ntrminutes.get()) + "\n")
    f.write("PctTx " + str(ipctx.get()) + "\n")
    f.write("DGain " + str(ndgain.get()) + "\n")
    f.write("Upload " + str(upload.get()) + "\n")
    f.write("Idle " + str(idle.get()) + "\n")
    f.write("Debug " + str(ndebug.get()) + "\n")
    f.write("WatScale " + str(s0) + "\n")
    f.write("WatOffset " + str(c0) + "\n")
    f.write("Palette " + g.cmap + "\n")
    mrudir2=mrudir.replace(" ","#")
    f.write("MRUdir " + mrudir2 + "\n")
    f.write("freq0_600 " + str( freq0[1]) + "\n")
    f.write("freqtx_600 " + str(freqtx[1]) + "\n")
    f.write("freq0_160 " + str( freq0[2]) + "\n")
    f.write("freqtx_160 " + str(freqtx[2]) + "\n")
    f.write("freq0_80 "  + str( freq0[3]) + "\n")
    f.write("freqtx_80 " + str(freqtx[3]) + "\n")
    f.write("freq0_60 "  + str( freq0[4]) + "\n")
    f.write("freqtx_60 " + str(freqtx[4]) + "\n")
    f.write("freq0_40 "  + str( freq0[5]) + "\n")
    f.write("freqtx_40 " + str(freqtx[5]) + "\n")
    f.write("freq0_30 "  + str( freq0[6]) + "\n")
    f.write("freqtx_30 " + str(freqtx[6]) + "\n")
    f.write("freq0_20 "  + str( freq0[7]) + "\n")
    f.write("freqtx_20 " + str(freqtx[7]) + "\n")
    f.write("freq0_17 "  + str( freq0[8]) + "\n")
    f.write("freqtx_17 " + str(freqtx[8]) + "\n")
    f.write("freq0_15 "  + str( freq0[9]) + "\n")
    f.write("freqtx_15 " + str(freqtx[9]) + "\n")
    f.write("freq0_12 "  + str( freq0[10]) + "\n")
    f.write("freqtx_12 " + str(freqtx[10]) + "\n")
    f.write("freq0_10 "  + str( freq0[11]) + "\n")
    f.write("freqtx_10 " + str(freqtx[11]) + "\n")
    f.write("freq0_6 "  + str( freq0[12]) + "\n")
    f.write("freqtx_6 " + str(freqtx[12]) + "\n")
    f.write("freq0_4 "  + str( freq0[13]) + "\n")
    f.write("freqtx_4 " + str(freqtx[13]) + "\n")
    f.write("freq0_2 "  + str( freq0[14]) + "\n")
    f.write("freqtx_2 " + str(freqtx[14]) + "\n")
    f.write("freq0_other "  + str( freq0[15]) + "\n")
    f.write("freqtx_other " + str(freqtx[15]) + "\n")
    f.write("iband " + str(iband.get()) + "\n")
    f.write("StartIdle " + str(start_idle.get()) + "\n")
    f.write("NoBeep " + str(no_beep.get()) + "\n")
    f.write("Reject " + str(nreject) + "\n")
    f.write("RxApply " + str(iq.iqrxapp.get()) + "\n")
    f.close()
    hopping.save_params(appdir)

#------------------------------------------------------ Top level frame
frame = Frame(root)

#------------------------------------------------------ Menu Bar
mbar = Frame(frame)
mbar.pack(fill = X)

#------------------------------------------------------ File Menu
filebutton = Menubutton(mbar, text = 'File')
filebutton.pack(side = LEFT)
filemenu = Menu(filebutton, tearoff=0)
filebutton['menu'] = filemenu
filemenu.add('command', label = 'Open', command = openfile, \
             accelerator='Ctrl+O')
filemenu.add('command', label = 'Open next in directory', command = opennext, \
             accelerator='F6')
filemenu.add('command', label = 'Decode remaining files in directory', \
             command = decodeall, accelerator='Shift+F6')
filemenu.add_separator()
filemenu.add('command', label = 'Delete all *.WAV files in Save', \
             command = delwav)
filemenu.add_separator()
filemenu.add('command', label = 'Erase ALL_WSPR.TXT', command = del_all)
filemenu.add_separator()
filemenu.add('command', label = 'Save user parameters', command = save_params)
filemenu.add_separator()
filemenu.add('command', label = 'Exit', command = quit, accelerator='Alt+F4')

#------------------------------------------------------ Setup menu
setupbutton = Menubutton(mbar, text = 'Setup')
setupbutton.pack(side = LEFT)
setupmenu = Menu(setupbutton, tearoff=0)
setupbutton['menu'] = setupmenu
setupmenu.add('command', label = 'Station parameters', command = options1,
              accelerator='F2')
setupmenu.add('command', label = 'Advanced', command = advanced1,
              accelerator='F7')
setupmenu.add('command', label = 'IQ Mode', command = iq1,
              accelerator='F8')
setupmenu.add('command', label = 'Band Hopping', command = hopping1,
              accelerator='F9')              
setupmenu.add_separator()
setupmenu.add_checkbutton(label = 'Always start in Idle mode',
                          variable=start_idle)
setupmenu.add_checkbutton(label = 'No beep when access to WSPRnet fails',
                          variable=no_beep)

#--------------------------------------------------------- View menu
viewbutton = Menubutton(mbar, text = 'View', )
viewbutton.pack(side = LEFT)
viewmenu = Menu(viewbutton, tearoff=0)
viewbutton['menu'] = setupmenu
viewmenu.palettes=Menu(setupmenu,tearoff=0)
viewmenu.palettes.add_radiobutton(label='Gray0',command=pal_gray0,
            value=0,variable=npal)
viewmenu.palettes.add_radiobutton(label='Gray1',command=pal_gray1,
            value=1,variable=npal)
viewmenu.palettes.add_radiobutton(label='Linrad',command=pal_linrad,
            value=2,variable=npal)
viewmenu.palettes.add_radiobutton(label='Blue',command=pal_blue,
            value=3,variable=npal)
viewmenu.palettes.add_radiobutton(label='Hot',command=pal_Hot,
            value=4,variable=npal)
viewmenu.palettes.add_radiobutton(label='AFMHot',command=pal_AFMHot,
            value=5,variable=npal)
viewmenu.add_cascade(label = 'Palette',menu=viewmenu.palettes)

#------------------------------------------------------ Mode menu
modebutton = Menubutton(mbar, text = 'Mode')
modebutton.pack(side = LEFT)
modemenu = Menu(modebutton, tearoff=0)
modebutton['menu'] = modemenu
modemenu.add_radiobutton(label = 'WSPR-2', variable=ntrminutes,value=2)
modemenu.add_radiobutton(label = 'WSPR-15', variable=ntrminutes,value=15)
ntrminutes.set(2)

#------------------------------------------------------ Save menu
savebutton = Menubutton(mbar, text = 'Save')
savebutton.pack(side = LEFT)
savemenu = Menu(savebutton, tearoff=0)
savebutton['menu'] = savemenu
savemenu.add_radiobutton(label = 'None', variable=nsave,value=0)
#savemenu.add_radiobutton(label = 'Save decoded', variable=nsave,value=1)
savemenu.add_radiobutton(label = 'Save all', variable=nsave,value=2)
nsave.set(0)

#------------------------------------------------------ Band menu
bandbutton = Menubutton(mbar, text = 'Band')
bandbutton.pack(side = LEFT)
bandmenu = Menu(bandbutton, tearoff=0)
bandbutton['menu'] = bandmenu
iband.set(6)
bandmenu.add_radiobutton(label = '600 m',variable=iband,value=1)
bandmenu.add_radiobutton(label = '160 m',variable=iband,value=2)
bandmenu.add_radiobutton(label = '80 m', variable=iband,value=3)
bandmenu.add_radiobutton(label = '60 m', variable=iband,value=4)
bandmenu.add_radiobutton(label = '40 m', variable=iband,value=5)
bandmenu.add_radiobutton(label = '30 m', variable=iband,value=6)
bandmenu.add_radiobutton(label = '20 m', variable=iband,value=7)
bandmenu.add_radiobutton(label = '17 m', variable=iband,value=8)
bandmenu.add_radiobutton(label = '15 m', variable=iband,value=9)
bandmenu.add_radiobutton(label = '12 m', variable=iband,value=10)
bandmenu.add_radiobutton(label = '10 m', variable=iband,value=11)
bandmenu.add_radiobutton(label = '6 m',  variable=iband,value=12)
bandmenu.add_radiobutton(label = '4 m',  variable=iband,value=13)
bandmenu.add_radiobutton(label = '2 m',  variable=iband,value=14)
bandmenu.add_radiobutton(label = 'Other',variable=iband,value=15)


#------------------------------------------------------  Help menu
helpbutton = Menubutton(mbar, text = 'Help')
helpbutton.pack(side = LEFT)
helpmenu = Menu(helpbutton, tearoff=0)
helpbutton['menu'] = helpmenu
helpmenu.add('command',label='Help',command=help,accelerator='F1')
helpmenu.add('command',label="Online WSPR User's Guide",command=usersguide, \
        accelerator='F3')
helpmenu.add('command',label="Online FMT User's Guide",command=fmtguide)
helpmenu.add('command',label="WSPRnet.org",command=wsprnet, \
        accelerator='F4')
helpmenu.add('command',label="WSJT Home Page",command=homepage)
helpmenu.add('command', label='About WSPR',command=about,accelerator='F5')
root.bind_all('<Escape>', stop_loopall)
root.bind_all('<F1>', help)
root.bind_all('<F2>', options1)
root.bind_all('<F3>', usersguide)
root.bind_all('<F4>', wsprnet)
root.bind_all('<Alt-F4>', quit)
root.bind_all('<F5>', about)
root.bind_all('<F6>', opennext)
root.bind_all('<F7>', advanced1)
root.bind_all('<F8>', iq1)
root.bind_all('<F9>', hopping1)
root.bind_all('<Shift-F6>', decodeall)
root.bind_all('<Control-o>',openfile)
root.bind_all('<Control-O>',openfile)

#------------------------------------------------------ Graphics area
iframe1 = Frame(frame, bd=1, relief=SUNKEN)

graph1=Canvas(iframe1, bg='black', width=NX, height=NY,cursor='crosshair')
Widget.bind(graph1,"<Motion>",df_readout)
Widget.bind(graph1,"<Double-Button-1>",set_tx_freq)
graph1.pack(side=LEFT)
c=Canvas(iframe1, bg='white', width=40, height=NY,bd=0)
c.pack(side=LEFT)

text1=Text(iframe1, height=10, width=15, bg='Navy', fg="yellow")
text1.pack(side=LEFT, padx=1)
text1.tag_configure('age0',foreground='red')
text1.tag_configure('age1',foreground='yellow')
text1.tag_configure('age2',foreground='gray75')
text1.tag_configure('age3',foreground='gray50')
text1.insert(END,'132 ZL1BPU')
sb = Scrollbar(iframe1, orient=VERTICAL, command=text1.yview)
sb.pack(side=RIGHT, fill=Y)
text1.configure(yscrollcommand=sb.set)
iframe1.pack(expand=1, fill=X, padx=4)

iframe2 = Frame(frame, bd=1, relief=FLAT)
sc1=Scale(iframe2,from_=-100.0,to_=100.0,orient='horizontal',
    showvalue=0,sliderlength=5)
sc1.pack(side=LEFT)
sc2=Scale(iframe2,from_=-100.0,to_=100.0,orient='horizontal',
    showvalue=0,sliderlength=5)
sc2.pack(side=LEFT)
balloon.bind(sc1,"Brightness")
balloon.bind(sc2,"Contrast")
bupload=Checkbutton(iframe2,text='Upload spots',justify=RIGHT,variable=upload)
balloon.bind(bupload,"Check to send spots to WSPRnet.org")
bupload.place(x=330,y=12, anchor='e')
bhopping=Checkbutton(iframe2,text='Band Hop',justify=RIGHT,variable=hopping.hopping)
bhopping.place(x=445,y=12, anchor='e')
bhopping.configure(state=DISABLED)
balloon.bind(bhopping,"Check to band hop; configure in Setup->Band Hopping")
lab00=Label(iframe2, text='Band Map').place(x=623,y=10, anchor='e')
lab02=Label(iframe2,text='',pady=5)
lab02.place(x=500,y=10, anchor='e')
iframe2.pack(expand=1, fill=X, padx=4)

#------------------------------------------------------ Stuff under graphics
iframe2a = Frame(frame, bd=1, relief=FLAT)
g1=Pmw.Group(iframe2a,tag_text="Frequencies (MHz)")
lf0=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Dial:',
        value=10.1387,entry_textvariable=sf0,entry_width=12,
        validate='real')
lftx=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Tx: ',
        value=10.140000,entry_textvariable=sftx,entry_width=12,validate='real')
widgets = (lf0,lftx)
for widget in widgets:
    widget.pack(side=TOP,padx=5,pady=4)
balloon.bind(lf0,"Set radio's dial frequency to this value and select USB mode")
balloon.bind(lftx,"Will transmit on this frequency")

Pmw.alignlabels(widgets)

g1.pack(side=LEFT,fill=BOTH,expand=0,padx=10,pady=6)
lab01=Label(iframe2a, text='').pack(side=LEFT,padx=1)
g2=Pmw.Group(iframe2a,tag_text="Tx fraction (%)")
#------------------------------------------------------ Tx percentage Select
pctscale=Scale(g2.interior(),orient=HORIZONTAL,length=350,from_=0, \
               to=100,tickinterval=10,variable=ipctx)
pctscale.pack(side=LEFT,padx=4)
balloon.bind(pctscale,"Select desired fraction of sequences to transmit")
ipctx.set(0)
g2.pack(side=LEFT,fill=BOTH,expand=0,padx=10,pady=6)
#------------------------------------------------------ Special controls
g3=Pmw.Group(iframe2a,tag_text='Special')
bidle=Checkbutton(g3.interior(),text='Idle       ',justify=RIGHT,variable=idle,width=5)
bidle.grid(row=0,column=1,padx=4,pady=3)
balloon.bind(bidle,"Check for no automatic T/R sequences")
bmute=Checkbutton(g3.interior(),text='Tx Mute',justify=RIGHT,variable=txmute,width=5)
bmute.grid(row=1,column=1,padx=4,pady=3)
balloon.bind(bmute,"Check for no Tx")
btune=Button(g3.interior(), text='Tune',underline=0,command=tune,width=9)
btune.grid(row=1,column=0,padx=2,pady=3)
balloon.bind(btune,"Transmit for number of seconds set by Tx fraction slider")
btxnext=Button(g3.interior(), text='Tx Next',underline=3,command=txnext,width=9)
btxnext.grid(row=0,column=0,padx=2,pady=3)
balloon.bind(btxnext,"Make the next 2-minute period a transmission")

##bstoptx=Button(g3.interior(), text='Stop Tx',underline=0,command=stoptx,width=9)
##bstoptx.grid(row=1,column=1,padx=2,pady=3)

g3.pack(side=LEFT,fill=X,expand=0,padx=10,pady=1)

iframe2a.pack(expand=1, fill=X, padx=1)

iframe2 = Frame(frame, bd=1, relief=FLAT,height=15)
lab2=Label(iframe2, text='UTC        dB        DT             Freq             Drift')
lab2.place(x=210,y=6, anchor='w')
iframe2.pack(expand=1, fill=X, padx=4)

#-------------------------------------------------------- UTC, etc
iframe4 = Frame(frame, bd=1, relief=FLAT)
f4aa=Frame(iframe4,height=170,bd=2,relief=RIDGE)
sm=smeter.Smeter(f4aa,fillColor='green',orientation='vertical', \
    width=10,height=170,doLabel=0,min=0,max=80)
sm.frame.pack(side=LEFT)

dgainscale=Scale(f4aa,orient=VERTICAL,length=170,from_=50, \
        to=-50,variable=ndgain,sliderlength=20,showvalue=0,width=9)
dgainscale.pack(side=LEFT,padx=4)
balloon.bind(dgainscale,"Digital gain control")
ndgain.set(0)

g2.pack(side=LEFT,fill=BOTH,expand=0,padx=10,pady=6)

f4aa.pack(side=LEFT,expand=0,fill=Y)

f4a=Frame(iframe4,height=170,bd=2,relief=RIDGE)

berase=Button(f4a, text='Erase',underline=0,command=erase,\
              width=9,padx=1,pady=1)
berase.pack(side=TOP,padx=0,pady=40)
balloon.bind(berase,"Erase decoded text and band map")

ldate=Label(f4a, bg='black', fg='yellow', width=11, bd=4,
        text='2005 Apr 22\n01:23:45', relief=RIDGE,
        justify=CENTER, font=(font1,14))
ldate.pack(side=TOP,padx=10,pady=0)
f4a.pack(side=LEFT,expand=0,fill=Y)

#--------------------------------------------------------- Decoded text box
f4b=Frame(iframe4,height=170,bd=2,relief=RIDGE)
text=Text(f4b, height=11, width=63, bg='white')
sb = Scrollbar(f4b, orient=VERTICAL, command=text.yview)
sb.pack(side=RIGHT, fill=Y)
text.pack(side=RIGHT, fill=X, padx=1)
text.insert(END,'1054   4 -25   1.12  10.140140  K1JT FN20 25')
text.configure(yscrollcommand=sb.set)
f4b.pack(side=LEFT,expand=0,fill=Y)
iframe4.pack(expand=1, fill=X, padx=4)


#------------------------------------------------------------ Status Bar
iframe6 = Frame(frame, bd=1, relief=SUNKEN)
msg1=Message(iframe6, text='      ', width=300,relief=SUNKEN)
msg1.pack(side=LEFT, fill=X, padx=1)
msg2=Message(iframe6, text='      ', width=300,relief=FLAT)
msg2.pack(side=LEFT, fill=X, padx=1)
msg3=Message(iframe6, text='      ',width=300,relief=FLAT)
msg3.pack(side=LEFT, fill=X, padx=1)
msg4=Message(iframe6, text='      ', width=300,relief=FLAT)
msg4.pack(side=LEFT, fill=X, padx=1)
balloon.configure(statuscommand=msg4)

msg5=Message(iframe6, text='      ', width=300,relief=FLAT)
msg6=Message(iframe6, text='      ', width=400,relief=SUNKEN)
msg6.pack(side=RIGHT, fill=X, padx=1)
msg5.pack(side=RIGHT, fill=X, padx=1)
iframe6.pack(expand=1, fill=X, padx=4)
frame.pack()

isync=1
iband.set(6)
idle.set(1)
ipctx.set(20)

#---------------------------------------------------------- Process INI file
try:
    f=open(appdir+'/WSPR.INI',mode='r')
    params=f.readlines()
except:
    params=""

badlist=[]
#----------------------------------------------------------- readinit
def readinit():
    global nparam,mrudir
    try:
        for i in range(len(params)):
            if badlist.count(i)>0:
                print 'Skipping bad entry in WSPR.INI:\a',params[i]
                continue
            key,value=params[i].split()
            if   key == 'WSPRGeometry': root.geometry(value)
            elif key == 'MyCall': options.MyCall.set(value)
            elif key == 'MyGrid': options.MyGrid.set(value)
            elif key == 'CWID': advanced.idint.set(value)
            elif key == 'dBm': options.dBm.set(value)
            elif key == 'PctTx': ipctx.set(value)
            elif key == 'DGain': ndgain.set(value)
            elif key == 'PttPort': options.PttPort.set(value)
            elif key == 'CatPort': options.CatPort.set(value)
            elif key == 'AudioIn':
                value=value.replace("#"," ")
                g.DevinName.set(value)
                try:
                    g.ndevin.set(int(value[:2]))
                except:
                    g.ndevin.set(0)
                options.DevinName.set(value)


            elif key == 'AudioOut':
                value=value.replace("#"," ")
                g.DevoutName.set(value)
                try:
                    g.ndevout.set(int(value[:2]))
                except:
                    g.ndevout.set(0)
                options.DevoutName.set(value)

            elif key == 'BFOfreq': advanced.bfofreq.set(value)
            elif key == 'Acal': advanced.Acal.set(value)
            elif key == 'Bcal': advanced.Bcal.set(value)
            elif key == 'CalEnable': advanced.encal.set(value)
            elif key == 'IQmode': iq.iqmode.set(value)
            elif key == 'IQrx': iq.iqrx.set(value)
            elif key == 'IQtx': iq.iqtx.set(value)
            elif key == 'FIQ': iq.fiq.set(value)
            elif key == 'Ntxphaf': iq.isc3a.set(value)
            elif key == 'PTTmode': options.pttmode.set(value)
            elif key == 'CATenable': options.cat_enable.set(value)
            elif key == 'SerialRate': options.serial_rate.set(int(value))
            elif key == 'DataBits': options.databits.set(int(value))
            elif key == 'StopBits': options.stopbits.set(int(value))
            elif key == 'Handshake': options.serial_handshake.set(value.replace("#"," ") )
            elif key == 'Rig':
                t=value.replace("#"," ")
                options.rig.set(t)
                options.rignum.set(int(t[:4]))
            elif key == 'Nsave': nsave.set(value)
            elif key == 'TRminutes': ntrminutes.set(value)
            elif key == 'Upload': upload.set(value)
            elif key == 'Idle': idle.set(value)
            elif key == 'Debug': ndebug.set(value)
            elif key == 'WatScale': sc1.set(value)
            elif key == 'WatOffset': sc2.set(value)
            elif key == 'Palette': g.cmap=value
            elif key == 'freq0_600': freq0[1]=float(value)
            elif key == 'freq0_160': freq0[2]=float(value)
            elif key == 'freq0_80': freq0[3]=float(value)
            elif key == 'freq0_60': freq0[4]=float(value)
            elif key == 'freq0_40': freq0[5]=float(value)
            elif key == 'freq0_30': freq0[6]=float(value)
            elif key == 'freq0_20': freq0[7]=float(value)
            elif key == 'freq0_17': freq0[8]=float(value)
            elif key == 'freq0_15': freq0[9]=float(value)
            elif key == 'freq0_12': freq0[10]=float(value)
            elif key == 'freq0_10': freq0[11]=float(value)
            elif key == 'freq0_6': freq0[12]=float(value)
            elif key == 'freq0_4': freq0[13]=float(value)
            elif key == 'freq0_2': freq0[14]=float(value)
            elif key == 'freq0_other': freq0[15]=float(value)
            elif key == 'freqtx_600': freqtx[1]=float(value)
            elif key == 'freqtx_160': freqtx[2]=float(value)
            elif key == 'freqtx_80': freqtx[3]=float(value)
            elif key == 'freqtx_60': freqtx[4]=float(value)
            elif key == 'freqtx_40': freqtx[5]=float(value)
            elif key == 'freqtx_30': freqtx[6]=float(value)
            elif key == 'freqtx_20': freqtx[7]=float(value)
            elif key == 'freqtx_17': freqtx[8]=float(value)
            elif key == 'freqtx_15': freqtx[9]=float(value)
            elif key == 'freqtx_12': freqtx[10]=float(value)
            elif key == 'freqtx_10': freqtx[11]=float(value)
            elif key == 'freqtx_6': freqtx[12]=float(value)
            elif key == 'freqtx_4': freqtx[13]=float(value)
            elif key == 'freqtx_2': freqtx[14]=float(value)
            elif key == 'freqtx_other': freqtx[15]=float(value)
            elif key == 'iband': iband.set(value)
            elif key == 'StartIdle': start_idle.set(value)
            elif key == 'NoBeep': no_beep.set(value)
            elif key == 'Reject': w.acom1.reject=float(value)
            elif key == 'RxApply': iq.iqrxapp.set(value)

            elif key == 'MRUdir':
                mrudir=value.replace("#"," ")
            nparam=i

    except:
        badlist.append(i)
        nparam=i

w.acom1.gain=1.0
w.acom1.phase=0.0
w.acom1.reject=0.
while nparam < len(params)-1:
    readinit()
hopping.restore_params(appdir)
iq.ib.set(iband.get())
iq.restore()

r=options.chkcall(options.MyCall.get())
if r<0:
    options.lcall._entryFieldEntry['background']='pink'
    options1()
else:
    options.lcall._entryFieldEntry['background']='white'
    
r=options.chkgrid(options.MyGrid.get())
if r<0:
    options.lgrid._entryFieldEntry['background']='pink'
    options1()
else:
    options.lgrid._entryFieldEntry['background']='white'

if g.DevinName.get()=="":
    g.ndevin.set(-1)

f0.set(freq0[iband.get()])
ftx.set(freqtx[iband.get()])

if start_idle.get():
    idle.set(1)

#------------------------------------------------------  Select palette
if g.cmap == "gray0":
    pal_gray0()
    npal.set(0)
if g.cmap == "gray1":
    pal_gray1()
    npal.set(1)
if g.cmap == "Linrad":
    pal_linrad()
    npal.set(2)
if g.cmap == "blue":
    pal_blue()
    npal.set(3)
if g.cmap == "Hot":
    pal_Hot()
    npal.set(4)
if g.cmap == "AFMHot":
    pal_AFMHot()
    npal.set(5)

options.dbm_balloon()
fmid=f0.get() + 0.001500
sftx.set('%.06f' % ftx.get())
draw_axis()
erase()
if g.Win32: root.iconbitmap("wsjt.ico")
Title='WSPR ' + Version + '    by K1JT'
root.title(Title)

put_params()
try:
    os.remove('decoded.txt')
except:
    pass
try:
    os.remove('pixmap.dat')
except:
    pass

##if hopping.hopping.get() and hopping.coord_bands.get() and not idle.get():
##    tsec=time.time()
##    utc=time.gmtime(tsec)
##    ns1=int(tsec) % 1200
##    b=ns1/120 + 3
##    if b==12: b=2
##    if hopping.hoppingflag[b].get():
##        iband.set(b)
## Issue rigctl command here

iband0=iband.get()
graph1.focus_set()
w.acom1.ndevsok=0
w.acom1.ntxnext=0
w.acom1.nstoptx=0
w.wspr1()
t="%.6f" % (f0.get(),)
sf0.set(t)
t="%.6f" % (ftx.get(),)
sftx.set(t)

ldate.after(100,update)
ldate.after(100,audio_config)

##from WsprMod import specjt
root.mainloop()

ldate.after_cancel(timer1)

# Clean up and save user options, then terminate.
if options.pttmode.get()=='CAT':
    if options.rignum.get()==2509 or options.rignum.get()==2511:
        cmd="rigctl -m %d -r %s T 0" % \
             (options.rignum.get(),options.CatPort.get())
    else:
        cmd="rigctl -m %d -r %s -s %d -C data_bits=%s -C stop_bits=%s -C serial_handshake=%s T 0" % \
             (options.rignum.get(),options.CatPort.get(), \
              options.serial_rate.get(),options.databits.get(), \
              options.stopbits.get(),options.serial_handshake.get())
    ierr=os.system(cmd)
save_params()
w.paterminate()
time.sleep(0.5)
