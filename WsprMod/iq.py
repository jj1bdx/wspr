#------------------------------------------------------------------ iq
from Tkinter import *
import Pmw
import g
import w
import time
import tkMessageBox
import pickle

def done():
    root.withdraw()

root=Toplevel()
root.withdraw()
root.protocol('WM_DELETE_WINDOW',done)
if g.Win32: root.iconbitmap("wsjt.ico")
root.title("I-Q Mode")

def iq2(t):
    root.geometry(t)
    root.deiconify()
    root.focus_set()
    j=ib.get()
    lab0.configure(text=str(mb[j])+' m')

iqmode=IntVar()
iqrx=IntVar()
iqtx=IntVar()
fiq=IntVar()
iqrxapp=IntVar()
iqrxadj=IntVar()

isc2=IntVar()
isc2.set(0)
isc2a=IntVar()
isc2a.set(0)
isc3=IntVar()
isc3.set(0)
isc3a=IntVar()
isc3a.set(0)

ib=IntVar()
gain=DoubleVar()
phdeg=DoubleVar()
mb=[0,600,160,80,60,40,30,20,17,15,12,10,6,4,2,0]
tbal=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
tpha=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
rbal=[1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]
rpha=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
allbands=0

def saveband(event=NONE):
    global allbands,tbal,tpha,rbal,rpha
    if allbands:
        for j in range(1,15):
            tbal[j]=isc2.get() + 0.02*isc2a.get()
            tpha[j]=isc3.get() + 0.02*isc3a.get()
            rbal[j]=w.acom1.gain
            rpha[j]=57.2957795*w.acom1.phase
    else:
        j=ib.get()
        tbal[j]=isc2.get() + 0.02*isc2a.get()
        tpha[j]=isc3.get() + 0.02*isc3a.get()
        rbal[j]=w.acom1.gain
        rpha[j]=57.2957795*w.acom1.phase

    f=open(g.appdir+'/iqpickle',mode='w')
    pickle.dump(tbal,f)    
    pickle.dump(tpha,f)    
    pickle.dump(rbal,f)    
    pickle.dump(rpha,f)    
    f.close()

def saveall(event=NONE):
    global allbands
    allbands=1
    saveband()
    allbands=0

def restore():
    global tbal,tpha,rbal,rpha
    try:
        f=open(g.appdir+'/iqpickle',mode='r')
        tbal=pickle.load(f)
        tpha=pickle.load(f)
        rbal=pickle.load(f)
        rpha=pickle.load(f)
        f.close()
    except:
        pass
    newband()

def newband():
    j=ib.get()
    lab0.configure(text=str(mb[j])+' m')
    w.acom1.gain=rbal[j]
    w.acom1.phase=rpha[j]/57.2957795
    isc2.set(int(tbal[j]))
    isc2a.set(int((tbal[j]-isc2.get())/0.02))
    isc3.set(int(tpha[j]))
    isc3a.set(int((tpha[j]-isc3.get())/0.02))

#-------------------------------------------------------- Create GUI widgets
g1=Pmw.Group(root,tag_pyclass=None)

lab0=Label(g1.interior(),text='160 m',bg='yellow',pady=5)
lab0.place(x=180,y=40, anchor='e')
#lab0.pack(anchor=W,padx=5,pady=4)


biqmode=Checkbutton(g1.interior(),text='Enable I/Q mode',variable=iqmode)
biqmode.pack(anchor=W,padx=5,pady=2)

biqtx=Checkbutton(g1.interior(),text='Reverse Tx I,Q',variable=iqtx)
biqtx.pack(anchor=W,padx=5,pady=2)

biqrx=Checkbutton(g1.interior(),text='Reverse Rx I,Q',variable=iqrx)
biqrx.pack(anchor=W,padx=5,pady=2)

biqrxapp=Checkbutton(g1.interior(),text='Apply Rx phasing corrections', \
        variable=iqrxapp)
biqrxapp.pack(anchor=W,padx=5,pady=2)

biqrxadj=Checkbutton(g1.interior(),text='Adjust Rx phasing', \
        variable=iqrxadj)
biqrxadj.pack(anchor=W,padx=5,pady=2)

lab1=Label(g1.interior(),text='',justify=LEFT)
lab1.pack(anchor=W,padx=5,pady=4)

fiq_entry=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Fiq (Hz):         ',
        value='12000',entry_textvariable=fiq,entry_width=10,
        validate={'validator':'integer','min':-24000,'max':24000,
        'minstrict':0,'maxstrict':0})
fiq_entry.pack(fill=X,padx=2,pady=4)

sc2=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=-30, \
        to=30,variable=isc2,label='Tx I/Q Balance (0.1 dB)', \
        relief=SOLID,bg='#EEDD82')
sc2.pack(side=TOP,padx=4,pady=2)

sc2a=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=-50, \
        to=50,variable=isc2a,label='Tx I/Q Balance (0.002 dB)', \
        relief=SOLID,bg='#EEDD82')
sc2a.pack(side=TOP,padx=4,pady=2)

sc3=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=-20, \
        to=20,variable=isc3,label='Tx Phase (deg)', \
        relief=SOLID,bg='#AFeeee')
sc3.pack(side=TOP,padx=4,pady=2)
sc3a=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=-50, \
        to=50,variable=isc3a,label='Tx Phase (0.02 deg)', \
        relief=SOLID,bg='#AFeeee')
sc3a.pack(side=TOP,padx=4,pady=2)

bsave=Button(g1.interior(), text='Save for this band',command=saveband,
             width=32,padx=1,pady=2)
bsave.pack(padx=2,pady=4)

bsaveall=Button(g1.interior(), text='Save for all bands',command=saveall,
             width=32,padx=1,pady=2)
bsaveall.pack(padx=2,pady=4)

f1=Frame(g1.interior(),width=100,height=1)
f1.pack()
g1.pack(side=LEFT,fill=BOTH,expand=1,padx=4,pady=4)
