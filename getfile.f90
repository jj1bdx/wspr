subroutine getfile(fname,len)
!f2py threadsafe

  character*(*) fname
  include 'acom1.f90'
  integer*1 hdr(44),n1
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
  common/hdr/ariff,lenfile,awave,afmt,lenfmt,nfmt2,nchan2, &
     nsamrate,nbytesec,nbytesam2,nbitsam2,adata,ndata,d2
  equivalence (ariff,hdr),(n1,n4),(d1,d2)

1 if(ndecoding.eq.0) go to 2
  call msleep(100)
  go to 1

!2 ndecoding=1
2  do i=len,1,-1
     if(fname(i:i).eq.'/' .or. fname(i:i).eq.'\\') go to 10
  enddo
  i=0
10  continue
  call cs_lock('getfile')
  open(10,file=fname,access='stream',status='old')
  read(10) hdr
  npts=114*12000
  if(ntrminutes.eq.15) npts=890*12000
  read(10) (iwave(i),i=1,npts)
  close(10)
  n4=1
  if (n1.eq.1) goto 8                     !skip byteswap if little endian
  do i=1,npts
     i4 = iwave(i)
     iwave(i) = ishft(iand(i4,255),8) +  iand(ishft(i4,-8),255)
  enddo    
8 call getrms(iwave,npts,ave,rms)
  ndecdone=0                              !??? ### ???
  ndiskdat=1
  outfile=fname
  nrxdone=1
  call cs_unlock

  return
end subroutine getfile
