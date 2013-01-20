  parameter (NMAX=900*12000)                          !Max length of waveform
  parameter (NZ=2*900*48000)
  real*8 f0,f0a,f0b,ftx,tsec0
  logical ltest,receiving,transmitting
  character*80 infile,outfile,pttport,thisfile
  character cdate*8,utctime*10,rxtime*4,catport*12
  character pttmode*3,appdir*80,chs*40
  character callsign*12,grid*4,grid6*6,ctxmsg*22,sending*22
  integer*2 iwave,kwave
  common/acom1/ f0,f0a,f0b,ftx,tsec0,rms,pctx,igrid6,nsec,ndevin,      &
       nfhopping,nfhopok,iband,ncoord,ntrminutes,                      &
       ndevout,nsave,nrxdone,ndbm,nport,ndec,ndecdone,ntxdone,         &
       idint,ndiskdat,ndecoding,ntr,nbaud,ndatabits,nstopbits,         &
       receiving,transmitting,nrig,nappdir,iqmode,iqrx,iqtx,nfiq,      &
       ndebug,idevin,idevout,nsectx,nbfo,iqrxapp,                      &
       ntxdb,txbal,txpha,iwrite,newdat,iqrxadj,gain,phase,reject,      &
       ntxfirst,ntest,ncat,ltest,iwave(NMAX),kwave(NZ),idle,ntune,     &
       ntxnext,nstoptx,ncal,ndevsok,nsec1,nsec2,xdb1,xdb2,             &
       infile,outfile,pttport,cdate,utctime,callsign,grid,grid6,       &
       rxtime,ctxmsg,sending,thisfile,pttmode,catport,appdir,chs
