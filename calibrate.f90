program calibrate

! Get calibration and alignment info for an HF Time-of-Arrival *.wav file.

  parameter (NFSMAX=12000)
  parameter (NMAX=300*NFSMAX)                !Max length of data
  parameter (NFFTMAX=4*1024*1024,NHMAX=NFFTMAX/2)
  character*40 infile,outfile
  integer*2 id(NMAX)                         !Integer data from *.wav file
  real x(NMAX)                               !Data converted to floats
  real xx(NFFTMAX)                           !Resampled data
  real xxa(NFFTMAX)                          !Resampled and time-aligned
  real prof(NFSMAX+5)                        !Folded profile, p=nfs
  real*8 p1                                  !Measured period of 1 PPS pulse
  real*8 samfac                              !Resample factor

  character cdate*8                          !CCYYMMDD
  character ctime*10                         !HHMMSS.SSS
  character*4 mode
  character*6 mycall,mygrid
  real*8 fkhz,tsec

  integer resample
  complex cxx(0:NHMAX)
  complex z1
  complex cal(35)
  equivalence (xx,cxx)

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage:   calibrate  <infile>'
     print*,'Example: calibrate K1JT_110209_214500.wav'
     go to 999
  endif

  call getarg(1,infile)
  open(12,file=infile,access='stream',status='old')
  call read_wav(12,id,npts,nfs,nch)                !Read data from *.wav file
  read(12) tsec,fkhz,mycall,mygrid,mode,ctime      !Get header info
  cdate='?'
  read(12,end=1) cdate
1 close(12)

  i1=index(infile,'.wav')
  outfile=infile(:i1-1)//'.prof'
  open(13,file=outfile,status='unknown')           !1 PPS profile

  outfile=infile(:i1-1)//'.bin'                    !Binary data
  open(14,file=outfile,form='unformatted',status='unknown')

  outfile=infile(:i1-1)//'.cal'                    !Calibration data
  open(15,file=outfile,status='unknown')

  dt=1.0/nfs
  n=log(float(npts))/log(2.0) + 0.9999
  nfft=2**n
  df=float(nfs)/nfft

  x(:npts)=id(:npts)                               !Convert to floats
  call averms(x,npts,ave,rms,xmax)                 !Get ave, rms
  x(:npts)=(1.0/rms)*(x(:npts)-ave)                !Remove DC and normalize

  ip1=nfs-1
  ip2=nfs
  call fold1pps(x,npts,ip1,ip2,prof,p1,peak,ipk)  !Find sample rates

  write(*,1010) mycall,mygrid,cdate,ctime(:6)
1010 format(a6,4x,a6,6x,'Date: ',a8,'   Time: ',a6)
  write(*,1011) fkhz,mode,float(npts)/nfs
1011 format('Freq:',f10.3,' kHz   Mode: ',a4,'   Duration:',f6.1' s')

! Resample ntype: 0=best, 1=sinc_medium, 2=sinc_fast, 3=hold, 4=linear
  ntype=1
  samfac=nfs/p1
  ierr=resample(x,xx,samfac,npts,ntype)    !Resample to nfs Hz, exactly
  if(ierr.ne.0) print*,'Resample error.',samfac
  npts1=samfac*npts
  npts=npts1

  xx(npts+1:nfft)=0.
  ip=nfs
  i1=ipk1+ip-100
  xxa(1:npts-i1+1)=xx(i1:npts)  !Align data so that 1 PPS is at start
  npts=npts-i1+1
  xxa(npts+1:nfft)=0.

  prof=0.
  do i=1,npts,nfs                           !Fold at p=nfs (exactly)
     prof(:ip)=prof(:ip) + xxa(i:i+ip-1)
  enddo

  pmax=0.
  do i=1,ip
     if(abs(prof(i)).gt.abs(pmax)) then
        pmax=prof(i)
        ipk=i
     endif
  enddo

  fac=1.0/pmax
  do i=0,ip-1
     i1=ipk+i
     if(i1.gt.ip) i1=i1-ip
     xx(i+1)=fac*prof(i1)
  enddo
  prof(:ip)=xx(:ip)                         !Save time-domain profile

  do i=-20,250
     j=i
     if(j.lt.1) j=j+ip
     write(13,1020) 1000.0*(i-1)*dt,prof(j)
1020 format(f12.3,f12.6)
  enddo

  call four2a(xx,ip,1,-1,0)                 !FFT of 1 PPS profile

  cal=0.
  do j=1,35                                 !Compute calibration array
     i=100*j
     z1=0.01*sum(cxx(i-50:i+49))
     cal(j)=z1
     s1=real(z1)**2 + aimag(z1)**2
     pha1=atan2(aimag(z1),real(z1))
     write(15,1030) i,db(s1),pha1
1030 format(i6,2f10.3)
  enddo

  print*,xxa(1:3)
  call averms(xxa,npts,ave,rms,xmax)                 !Get ave, rms
  fac=100.0
  if(xmax.gt.200.0) fac=20000.0/xmax
  id(:npts)=fac*xxa(:npts)
  write(14) tsec,fkhz,mycall,mygrid,mode,ctime,cdate,ip,npts,fac,      &
       prof(:ip),cal,id(:npts)

999 end program calibrate
