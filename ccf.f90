program ccf

! Correlate two-station recordings for HF Time-of-Arrival project.

  parameter (NFSMAX=48000)
  parameter (NMAX=300*NFSMAX)                !Max length of data
  parameter (NFFTMAX=4*1024*1024,NHMAX=NFFTMAX/2)
  integer*2 id1(NMAX),id2(NMAX)              !Sampled data
  real*4 x1(NMAX),x2(NMAX)
  character arg*12                           !Command-line arg
  character*40 file1,file2
  real prof1(NFSMAX),prof2(NFSMAX)
  real*8 p1,p2,samfac1,samfac2
  integer resample
  real xx1(NFFTMAX),xx2(NFFTMAX),xx(NFFTMAX),xx1pps(NFFTMAX)
  real xx1a(NFFTMAX),xx2a(NFFTMAX)
  real xcf1(-512:12511),xcf2(-512:12511)
  real rfil(0:NHMAX)

  character cdate*8                          !CCYYMMDD
  character ctime*10                         !HHMMSS.SSS
  character*4 mode1,mode2
  character*6 call1,call2,grid1,grid2
  real*8 fkhz,tsec

  complex c1(0:NHMAX),c2(0:NHMAX),cc(0:NHMAX)
  complex z1,z2
  complex cal1(35),cal2(35)
  data pi/3.14159265/
  equivalence (xx1,c1),(xx2,c2),(xx,cc)

  nargs=iargc()
  if(nargs.ne.4) then
     print*,'Usage:   ccf <f1>  <f2>       <file1>                <file2>'
     print*,'Example: ccf  300  3000  K1JT_110209_024500.wav AA6E_110209_024500.wav'
     go to 999
  endif

  call getarg(1,arg)
  read(arg,*) nf1
  call getarg(2,arg)
  read(arg,*) nf2
  call getarg(3,file1)
  call getarg(4,file2)
  open(12,file=file1,access='stream',status='old')
  call read_wav(12,id1,npts1,nfs1,nch1)       !Read data from disk
  if(file1(1:4).ne.'K9AN') then
     read(12) tsec,fkhz,call1,grid1,mode1,ctime      !Get header info
     cdate='?'
     read(12,end=1) cdate
  endif
1 close(12)

  open(12,file=file2,access='stream',status='old')
  call read_wav(12,id2,npts2,nfs2,nch2)
  read(12) tsec,fkhz,call2,grid2,mode2,ctime      !Get header info
  cdate='?'
  read(12,end=2) cdate
2  close(12)

  open(32,file='ccfprof.dat',status='unknown')
  open(33,file='ccfcal.dat',status='unknown')
  open(34,file='ccf.out',status='unknown')

  if(nfs1.ne.nfs2) then
     print*,'Mismatched sample rates:',nfs1,nfs2
     go to 999
  endif

  nfs=nfs1
  npts0=min(npts1,npts2)
  npts=npts0
  dt=1.0/nfs
  n=log(float(npts))/log(2.0) + 0.9999
  nfft=2**n
  df=float(nfs)/nfft

  x1(:npts)=id1(:npts)
  x2(:npts)=id2(:npts)

  call averms(x1,npts,ave1,rms1,xmax1)       !Get ave, rms
  call averms(x2,npts,ave2,rms2,xmax2)
  x1(:npts)=(1.0/rms1)*(x1(:npts)-ave1)       !Remove DC and normalize
  x2(:npts)=(1.0/rms2)*(x2(:npts)-ave2)

  ip1=nfs-1
  ip2=nfs
  call fold1pps(x1,npts,ip1,ip2,prof1,p1,pk1,ipk1)  !Find sample rates
  call fold1pps(x2,npts,ip1,ip2,prof2,p2,pk2,ipk2)

  write(*,1010) call1,grid1,cdate,ctime(:6),ave1,rms1,xmax1
  write(*,1010) call2,grid2,cdate,ctime(:6),ave2,rms2,xmax2
1010 format(a6,2x,a6,2x,'UTC: ',a8,1x,a6,'  Ave:',f8.1,'  Rms:',    &
          f8.1,'  Max:',f8.1)
  write(*,1011) fkhz,mode1,float(npts)/nfs
1011 format('Freq:',f10.3,' kHz   Mode: ',a4,'   Duration:',f6.1' s')

! Resample ntype: 0=best, 1=sinc_medium, 2=sinc_fast, 3=hold, 4=linear
  ntype=3
  samfac1=nfs/p1
  ierr=resample(x1,xx1,samfac1,npts,ntype)    !Resample to nfs Hz, exactly
  if(ierr.ne.0) print*,'Resample error.',samfac1
  npts1=samfac1*npts

  samfac2=nfs/p2
  ierr=resample(x2,xx2,samfac2,npts,ntype)
  if(ierr.ne.0) print*,'Resample error.',samfac2
  npts2=samfac2*npts
  npts=min(npts1,npts2)

  xx1(npts+1:nfft)=0.
  xx2(npts+1:nfft)=0.
  ip=nfs
  i1=ipk1+ip-100
  xx1a(1:npts-i1+1)=xx1(i1:npts)  !Align data so that 1 PPS is at start
  i2=ipk2+ip-100
  xx2a(1:npts-i2+1)=xx2(i2:npts)
  npts=min(npts-i1+1,npts-i2+1)
  xx1a(npts+1:nfft)=0.
  xx2a(npts+1:nfft)=0.

  prof1=0.
  prof2=0.
  do i=1,npts,nfs                           !Fold at p=nfs (exactly)
     prof1(:ip)=prof1(:ip) + xx1a(i:i+ip-1)
     prof2(:ip)=prof2(:ip) + xx2a(i:i+ip-1)
  enddo

  pmin1=0.
  pmin2=0.
  do i=1,ip
     if(prof1(i).lt.pmin1) then
        pmin1=prof1(i)
        ipk1=i
     endif
     if(prof2(i).lt.pmin2) then
        pmin2=prof2(i)
        ipk2=i
     endif
  enddo

  fac1=-1.0/pmin1
  fac2=-1.0/pmin2
  do i=0,ip-1
     i1=ipk1+i
     if(i1.gt.ip) i1=i1-ip
     i2=ipk2+i
     if(i2.gt.ip) i2=i2-ip
     xx1(i+1)=fac1*prof1(i1)
     xx2(i+1)=fac2*prof2(i2)
  enddo

  do i=-20,250
     j=i
     if(j.lt.1) j=j+ip
     write(32,1020) 1000.0*i*dt,xx1(j),xx2(j)
1020 format(f12.3,2f10.3)
  enddo

  call four2a(xx1,ip,1,-1,0)                !FFTs of 1 PPS profiles
  call four2a(xx2,ip,1,-1,0)

  do j=1,35                                 !Compute calibration arrays
     i=100*j
     z1=0.01*sum(c1(i-50:i+49))
     z2=0.01*sum(c2(i-50:i+49))
     cal1(j)=z1/8.0
     cal2(j)=z2
     s1=real(z1)**2 + aimag(z1)**2
     s2=real(z2)**2 + aimag(z2)**2
     pha1=atan2(aimag(z1),real(z1))
     pha2=atan2(aimag(z2),real(z2))
     write(33,1030) i,db(s1),pha1,db(s2),pha2
1030 format(i6,4f10.3)
  enddo

  xx1=xx1a
  xx2=xx2a
  nchop=200
  do i=nchop,npts,nfs                         !Keep only the 1PPS pulse
     xx1(i:i+nfs-nchop)=0.
     xx2(i:i+nfs-nchop)=0.
  enddo

  call four2a(xx1,nfft,1,-1,0)              !Forward FFTs of 1PPS pulses
  call four2a(xx2,nfft,1,-1,0)

  fac=1.e-12
  cc=0.
  ia=100/df                                 !Define rectangular passband
  ib=3500/df
  rfil=0.
  do i=ia,ib
     j=nint(0.01*i*df)
     z1=c1(i)/cal1(j)                       !Apply calibrations
     z2=c2(i)/cal2(j)
     cc(i)=fac*z1*conjg(z2)                 !Multiply transforms
     f=i*df
     rfil(i)=1.0 
     if(f.lt.float(nf1)) rfil(i)=exp(-((f-nf1)/300.0)**2)
     if(f.gt.float(nf2)) rfil(i)=exp(-((f-nf2)/300.0)**2)
!     if(mod(i,1000).eq.0) write(37,7001) f,rfil(i)
!7001 format(f12.3,f12.6)
     cc(i)=cc(i)*rfil(i)
     cc(i)=conjg(cc(i))
  enddo

  call four2a(cc,nfft,1,1,-1)        !Inverse FFT ==> CCF of 1 PPS pulses
  xx1pps=xx*sqrt(float(nfs)/nchop)

  xx1=xx1a
  xx2=xx2a
  do i=1,npts,nfs                           !Keep signal without 1 PPS pulses
     xx1(i:i+nchop)=0.
     xx2(i:i+nchop)=0.
  enddo

  call four2a(xx1,nfft,1,-1,0)              !Forward FFTs of signal
  call four2a(xx2,nfft,1,-1,0)

  fac=8*1.e-12
  cc=0.
  do i=ia,ib
     j=nint(0.01*i*df)
     z1=c1(i)/cal1(j)                       !Apply calibrations
     z2=c2(i)/cal2(j)
     cc(i)=fac*z1*conjg(z2)                 !Multiply transforms
     cc(i)=cc(i)*rfil(i)
     cc(i)=conjg(cc(i))
  enddo

  call four2a(cc,nfft,1,1,-1)               !Inverse FFT ==> CCF of signal

  i1=-512
!  i2=511
  i2=12511
  pk1=0.
  pk2=0.
  do i=i1,i2
     j=i
     if(j.le.0) j=i+nfft
     xcf1(i)=xx1pps(j)
     xcf2(i)=xx(j)
     pk1=max(pk1,xcf1(i))
     pk2=max(pk2,xcf2(i))
  enddo

  xpk1=0.
  xpk2=0.
  do i=i1,i2
     xcf1(i)=xcf1(i)/pk1
     xcf2(i)=xcf2(i)/pk2
     write(34,1110) 1000.0*i*dt,xcf1(i),xcf2(i)       !Write CCFs to disk
1110 format(f10.3,2f12.6)
     if(xcf1(i).gt.xpk1) then
        xpk1=xcf1(i)
        ipk1=i
     endif
     if(xcf2(i).gt.xpk2) then
        xpk2=xcf2(i)
        ipk2=i
     endif
  enddo
  write(*,1112) samfac1,samfac2,1000.0*(ipk2-ipk1)*dt
1112 format('sf1:', f12.9,'   sf2:',f12.9,'   Delay:',f8.2)

  nfft2=1024
  xx1(:nfft2)=xcf1(-512:511)
  xx2(:nfft2)=xcf2(-512:511)
  call four2a(xx1,nfft2,1,-1,0)
  call four2a(xx2,nfft2,1,-1,0)
  df2=float(nfs)/nfft2
  iz=3500.0/df2
  do i=1,iz
     s1=real(c1(i))**2 + aimag(c1(i))**2
     s2=real(c2(i))**2 + aimag(c2(i))**2
     write(35,1120) i*df2,s1,s2,db(s1),db(s2)
1120 format(f10.3,2f12.1,2f12.3)
  enddo

999 end program ccf
