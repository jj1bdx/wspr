program t1

! Find time delay between 1 PPS ticks from GPS and WWV.

  parameter (NFSMAX=48000)
  parameter (NMAX=310*NFSMAX)                !Max length of data
  character cdate*8                          !CCYYMMDD
  character ctime*6                         !HHMMSS.SSS
  character*6 mycall,mygrid
  character cjunk*1
  real*8 p1
  integer iipk(1)
  real prof1(NFSMAX)
  real xx(NFSMAX)
  real notch(-20:20)
  complex c(0:NFSMAX/2)
  complex cal1(0:35)
  real ccf1(0:NFSMAX/6),ccf2(0:NFSMAX/6)
  real delay(4)
  real snr(4)
  equivalence (iipk,ipk)
  equivalence (xx,c)

  open(20,file='wwv.bin',form='unformatted',status='old')
  open(21,file='cal.dat',status='unknown')

  nfs=48000
  ip=nfs
  dt=1.0/nfs
  lagmax=nfs/6
  irec=0
  iz=0.150/dt

  do j=1,35
     read(21,1001) jj,cal1(j)
1001 format(i6,2f10.3)
     f=j*100.0
     x=0.
     if(f.lt.300.0) x=(f-300.0)/200.0
     if(f.gt.3000.0) x=(3000-f)/200.0
     cal1(j)=exp(-x*x)/cal1(j)
  enddo
  cal1(0)=0.

  do i=-20,20
     x=float(i)/20.0
     notch(i)=1.0 - exp(-x*x)
  enddo

10 irec=irec+1
  read(20,end=999)  cdate,ctime,day,xdelay,ccfmax1,ikhz,p1,mycall,mygrid,prof1
  read(ctime(4:4),*) i10
  xx=prof1

  iipk=maxloc(xx)
  do i=1,ip
     j=ipk+i-nint(0.001/dt)
     if(j.lt.1)  j=j+ip
     if(j.gt.ip) j=j-ip
     t=1000.0*i*dt - 1.0
     write(13,3001) t,xx(j)
3001 format(2f10.3)
  enddo

  call four2a(xx,ip,1,-1,0)                !Forward FFT of profile

  df=float(nfs)/ip
  ib=nint(3500.0/df)
  do i=0,ib
     j=nint(0.01*i*df)
     c(i)=c(i)*cal1(j)
  enddo
!  c(0)=0.
  c(ib:)=0.
  c(95:105)=0.
  if(ctime(3:4).eq.'02') then
     c(420:460)=c(420:460)*notch
  else
     if(mod(i10,2).eq.1) then
        c(580:620)=c(580:620)*notch
     else
        c(480:520)=c(480:520)*notch
     endif
  endif

!  do i=0,ib
!     s=real(c(i))**2 + aimag(c(i))**2
!     pha=atan2(aimag(c(i)),real(c(i)))
!     write(13,1030) i*df,s,db(s),pha
!1030 format(f10.3,f12.3,2f10.3)
!  enddo

  call four2a(c,ip,1,1,-1)             !Inverse FFT ==> calibrated profile

  fac=6.62/ip
  xx=fac*xx

  iipk=maxloc(xx)
  do i=1,ip
     j=ipk+i-nint(0.001/dt)
     if(j.lt.1)  j=j+ip
     if(j.gt.ip) j=j-ip
     t=1000.0*i*dt - 1.0
     write(14,3001) t,xx(j)
  enddo

  call clean(xx,ipk,snr,delay,nwwv,nd)

  do i=1,nd
     write(*,1000) irec,ctime,day,ikhz,snr(i),delay(i)
     write(16,1000) irec,ctime,day,ikhz,snr(i),delay(i)
1000 format(i6,2x,a6,f10.4,i7,2f8.2)
  enddo

  call flush(13)
  call flush(14)
  call flush(16)
  rewind 13
  rewind 14

  read*,cjunk
  if(cjunk.eq.'q') go to 999
  go to 10

999 end program t1
