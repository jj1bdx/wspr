program wwv

! Find time delay between 1 PPS ticks from GPS and WWV.

  parameter (NFSMAX=48000)
  parameter (NMAX=1210*NFSMAX)                !Max length of data
  integer*2 id(NMAX)                         !Raw data
  character arg*12                           !Command-line arg
  character cdate*8                          !CCYYMMDD
  character ctime*10                         !HHMMSS.SSS
  character*120 cmnd0,cmnd                   !Command to set rig frequency
  character*6 mycall,mygrid
  character param*5
  real*8 tsec,fkhz,p1,samfac,day2011
  real x1(NMAX),xx1(NMAX)
  real prof1(NFSMAX+5)
  real xx(NFSMAX+5)
  real notch(-20:20)
  real snr(4)
  real delay(4)
  complex c(0:NFSMAX/2)
  complex cal1(0:35)
  integer iipk(1)
  integer soundin
  integer resample
  integer time
  integer nkhz(0:4)
  integer nwwv(4)
  equivalence (iipk,ipk)
  equivalence (xx,c)
  data nkhz/2500,5000,10000,15000,20000/
  data nloop/-1/,nHz0/-99/

  nargs=iargc()
  if(nargs.lt.1 .or. nargs.gt.2) go to 998

  open(10,file='fmt.ini',status='old',err=910)  !Open this WSPR file
  read(10,'(a120)') cmnd0              !Get rigctl command to set frequency
  read(10,*) ndevin                    !Get audio device number
  read(10,*) mycall                    !Get my callsign
  read(10,*) mygrid                    !Get my grid locator
  close(10)

  open(13,file='prof.dat',status='unknown')  !Files for 1PPS+WWV profiles
  open(14,file='short.dat',status='unknown')

  dtmin=2.0
  dtmax=40.0
  dbmin=0.0
  nsave=1
  open(10,file='wwv.ini',status='old',err=1)  !Optional parameter file
  read(10,*) param,dtmin
  read(10,*) param,dtmax
  read(10,*) param,dbmin
  read(10,*) param,nsave
  close(10)

1 nfs=48000                                  !Sample rate
  dt=1.0/nfs
  nchan=1                                    !Single-channel recording
  call soundinit                             !Initialize Portaudio

  call getarg(1,arg)
  if(arg(:2).eq.'-v') then
     print*,'Version 1.04'
     go to 999
  else if(arg.eq.'cal' .or. arg.eq.'CAL') then
     nsec=60
     if(nargs.eq.2) then
        call getarg(2,arg)
        read(arg,*) nsec
     endif
     call calobs(nfs,nsec,ndevin,id,x1)
     go to 999
  endif

  fkhz=0.
  if(arg.ne.'all' .and. arg.ne.'ALL') read(arg,*) fkhz    !Rx frequency (kHz)

  open(10,file='cal.dat',status='old',err=920) !Open previously recorded cal.dat
  do j=1,35
     if(j.eq.1) read(10,1001) jj,cal1(j),p1
     if(j.ne.1) read(10,1001) jj,cal1(j)
1001 format(i6,2f10.3,f13.4)
     f=j*100.0
     x=0.
     if(f.lt.300.0) x=(f-300.0)/200.0
     if(f.gt.3000.0) x=(3000-f)/200.0
     cal1(j)=exp(-x*x)/cal1(j)
  enddo
  cal1(0)=0.
  close(10)

  do i=-20,20
     x=float(i)/20.0
     notch(i)=1.0 - exp(-x*x)
  enddo

  open(16,file='delay.dat',status='unknown',position='append')
  open(20,file='wwv.bin',form='unformatted',status='unknown',position='append')

  npts=nfs*51

10 nloop=nloop+1
  if(fkhz.gt.0.d0) then
     nHz=nint(1.d3*fkhz)
  else
     nHz=1000*nkhz(mod(nloop,5))
  endif
  
  if(nHz.ne.nHz0 .and. cmnd0(:6).eq.'rigctl') then
     cmnd=cmnd0
     i1=index(cmnd,' F ')
     write(cmnd(i1+2:),*) nHz                   !Insert desired frequency
     iret=system(cmnd)                          !Set Rx frequency
     if(iret.ne.0) then
        print*,'Error executing rigctl command to set frequency:'
        print*,cmnd
        go to 999
     endif

     cmnd(i1+1:)='M AM 0'
     iret=system(cmnd)                          !Set Rx mode
     if(iret.ne.0) then
        print*,'Error executing rigctl command to set Rx mode:'
        print*,cmnd
        go to 999
     endif
     nHz0=nHz
  endif

  call getutc(cdate,ctime,tsec)
  do while (ctime(5:6).ne.'01')
     call getutc(cdate,ctime,tsec)
     call msleep(100)
  enddo

  ierr=soundin(ndevin,nfs,id,npts,nchan-1)   !Get audio data
  if(ierr.ne.0) then
     print*,'Error in soundin',ierr
     stop
  endif

  x1(:npts)=id(:npts)
  call averms(x1,npts,ave1,rms1,xmax1)        !Get ave, rms
  x1(:npts)=(1.0/rms1)*(x1(:npts)-ave1)       !Remove DC and normalize

! Resample ntype: 0=best, 1=sinc_medium, 2=sinc_fast, 3=hold, 4=linear
  ntype=1
  samfac=nfs/p1
  ierr=resample(x1,xx1,samfac,npts,ntype)    !Resample to nfs Hz, exactly
  if(ierr.ne.0) print*,'Resample error.',samfac
  npts=samfac*npts

  ip=nfs
  prof1=0.
  do i=1,npts,nfs                           !Fold at p=nfs (exactly)
     prof1(:ip)=prof1(:ip) + xx1(i:i+ip-1)
  enddo

  pmax=0.
  do i=1,ip
     if(abs(prof1(i)).gt.abs(pmax)) then
        pmax=prof1(i)
        ipk=i
     endif
  enddo
  prof1(:ip)=prof1(:ip)/pmax
  xx=prof1

  if(nsave.ne.0) then
!     iipk=maxloc(prof1)
     i0=0.001/dt
     rewind 13
     rewind 14
     do i=1,ip
        j=ipk+i-100
        if(j.lt.1)  j=j+ip
        if(j.gt.ip) j=j-ip
        write(13,1010) 1000.0*(i-1)*dt,prof1(j)
1010 format(2f10.3)
        t=1000.0*(i-i0)*dt
        if(t.ge.-1.0 .and. t.le.dtmax) then
           j=ipk+i-i0
           if(j.lt.1) j=j+ip
           if(j.gt.ip) j=j-ip
           write(14,1010) t,prof1(j)
        endif
     enddo
     call flush(13)
     call flush(14)
  endif

  call four2a(xx,ip,1,-1,0)                !Forward FFT of profile

  df=float(nfs)/ip
  ib=nint(3500.0/df)
  do i=0,ib
     j=nint(0.01*i*df)
     c(i)=c(i)*cal1(j)
  enddo

  c(ib:)=0.
  c(95:105)=0.
  if(ctime(3:4).eq.'02') then
     c(420:460)=c(420:460)*notch
  else
     read(ctime(4:4),*) i10
     if(mod(i10,2).eq.1) then
        c(580:620)=c(580:620)*notch
     else
        c(480:520)=c(480:520)*notch
     endif
  endif

  call four2a(c,ip,1,1,-1)             !Inverse FFT ==> calibrated profile

  fac=6.62/ip
  xx=fac*xx
  iipk=maxloc(xx)

  call clean(xx,ipk,dtmin,dtmax,dbmin,snr,delay,nwwv,nd)

  day2011=time()/86400.d0 - 14974.d0
  ikhz=nhz/1000
  do i=1,nd
     write(*,1000)  cdate,ctime(1:6),day2011,ikhz,snr(i),delay(i),nwwv(i)
     write(16,1000) cdate,ctime(1:6),day2011,ikhz,snr(i),delay(i),nwwv(i)
1000 format(a8,2x,a6,f10.4,i7,f7.1,f8.2,i4)
  enddo

  call flush(16)
  go to 10

910 print*,'Cannot open file: fmt.ini'
  go to 999
920 print*,'Cannot open file: cal.dat'
  go to 999

998 print*,'Usage: wwv cal <nsec>      (Calibration, 1 PPS only)'
  print*,  '       wwv <f_kHz>         (1 PPS and WWV at one frequency)'
  print*,  '       wwv all             (1 PPS and WWV at all frequencies)'
  print*,  '       wwv -v              (Print version number and exit'

999 end program wwv
