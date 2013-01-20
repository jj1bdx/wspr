subroutine rx

! Receive WSPR signals for one 2-minute sequence.

  integer time

  integer soundin
  include 'acom1.f90'

  npts=114*12000
  if(ntrminutes.eq.15) npts=890*12000
  if(ncal.eq.1) npts=65536
  nsec1=time()
  nfhopok=0                                !Don't hop! 
  f0a=f0                                   !Save rx frequency at start
  ierr=soundin(ndevin,48000,kwave,4*npts,iqmode)
  if(f0a.ne.f0) then
     call cs_lock('rx')
!     write(70,*) 'Error in rx.f90 ',utctime,f0,f0a
!     call flush(70)
     f0a=f0
     call cs_unlock
  endif
  nfhopok=1                                !Data acquisition done, can hop 
  if(ierr.ne.0) then
     print*,'Error in soundin',ierr
     stop
  endif

  if(iqmode.eq.1) then
     call iqdemod(kwave,4*npts,nfiq,nbfo,iqrx,iqrxapp,gain,phase,iwave)
  else
     call fil1(kwave,4*npts,iwave,n2)       !Filter and downsample
     npts=n2
  endif
  nsec2=time()
  call getrms(iwave,npts,ave,rms)           !### is this needed any more??
  call cs_lock('rx')
  nrxdone=1
  if(ncal.eq.1) ncal=2
  call cs_unlock

  return
end subroutine rx

