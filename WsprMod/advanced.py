#------------------------------------------------------ advanced
from Tkinter import *
import Pmw
import g
import w
import time
import tkMessageBox

def done():
    root.withdraw()

root=Toplevel()
root.withdraw()
root.protocol('WM_DELETE_WINDOW',done)
if g.Win32: root.iconbitmap("wsjt.ico")
root.title("Advanced")

def advanced2(t):
    root.geometry(t)
    root.deiconify()
    root.focus_set()

idint=IntVar()
bfofreq=IntVar()
idint=IntVar()
igrid6=IntVar()
isc1=IntVar()
isc1.set(0)
encal=IntVar()
fset=IntVar()
Acal=DoubleVar()
Bcal=DoubleVar()
fset.set(0)

#------------------------------------------------------ freqcal
def freqcal(event=NONE):
    if w.acom1.ncal==0:
        bmeas.configure(bg='green')
        w.acom1.ncal=1

#-------------------------------------------------------- readab
def readab(event=NONE):
    try:
        f=open('fcal.out','r')
        s=f.readlines()
        f.close
        Acal.set(float(s[0]))
        Bcal.set(float(s[1]))
        encal.set(1)
    except:
        t='Cannot open fcal.out, or invalid data in file'
        result=tkMessageBox.showwarning(message=t)
        Acal.set(0.0)
        Bcal.set(0.0)

#-------------------------------------------------------- setfreq
def setfreq(event=NONE):
    fset.set(1)

#-------------------------------------------------------- Create GUI widgets
g1=Pmw.Group(root,tag_pyclass=None)

t="""
Important:   please read the WSPR User's
Guide (F3 key) before using features on
this screen.
"""
lab1=Label(g1.interior(),text=t,justify=LEFT)
lab1.pack(fill=X,expand=1,padx=5,pady=0)

sc1=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=-30, \
        to=0,variable=isc1,label='Reduce Tx Audio (dB)',relief=SOLID,bg='#FFC0CB')
sc1.pack(side=TOP,padx=4,pady=4)

cwid=Pmw.EntryField(g1.interior(),labelpos=W,label_text='CW ID (min):',
        value='0',entry_textvariable=idint,entry_width=5,
        validate={'validator':'numeric','min':0,'max':60})
cwid.pack(fill=X,padx=2,pady=2)
rxbfo=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Rx BFO (Hz): ',
        value='1500',entry_textvariable=bfofreq,entry_width=10,
        validate={'validator':'real','min':-3000,'max':3000})
rxbfo.pack(fill=X,padx=2,pady=2)
enable_cal=Checkbutton(g1.interior(),text='Enable frequency correction',
                   variable=encal)
enable_cal.pack(anchor=W,padx=5,pady=5)
A_entry=Pmw.EntryField(g1.interior(),labelpos=W,label_text='A (Hz):',
        value='0.0',entry_textvariable=Acal,entry_width=10,
        validate={'validator':'real','min':-100.0,'max':100.0,
        'minstrict':0,'maxstrict':0})
A_entry.pack(fill=X,padx=2,pady=2)
B_entry=Pmw.EntryField(g1.interior(),labelpos=W,label_text='B (ppm):',
        value='0.0',entry_textvariable=Bcal,entry_width=10,
        validate={'validator':'real','min':-100.0,'max':100.0,
        'minstrict':0,'maxstrict':0})
B_entry.pack(fill=X,padx=2,pady=2)
Pmw.alignlabels([cwid,rxbfo,A_entry,B_entry])

bmeas=Button(g1.interior(), text='Measure an audio frequency',command=freqcal,
             width=26,padx=1,pady=2)
bmeas.pack(padx=5,pady=5)

breadab=Button(g1.interior(), text='Read A and B from fcal.out',command=readab,
             width=26,padx=1,pady=2)
breadab.pack(padx=5,pady=5)

bsetfreq=Button(g1.interior(), text='Update rig frequency',command=setfreq,
             width=26,padx=1,pady=2)
bsetfreq.pack(padx=5,pady=5)
bgrid6=Checkbutton(g1.interior(),text='Force transmission of 6-digit locator',
                   variable=igrid6)
bgrid6.pack(anchor=W,padx=5,pady=2)

f1=Frame(g1.interior(),width=100,height=10)
f1.pack()
g1.pack(side=LEFT,fill=BOTH,expand=1,padx=4,pady=4)
