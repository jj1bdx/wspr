program fmtiq

! Program for ARRL Frequency Measuring Test, etc.

  parameter (NFFT=512*1024)                     !Length of complex waveform
!  parameter (NFFT=128*1024)                     !Length of complex waveform
  integer*2 iwave(2,NFFT)
  character arg*12,cmnd*120
  complex c(0:NFFT-1)
  real s1(NFFT)
  real*8 s,sq
  integer time
  integer soundin
  equivalence (x,c)

  nargs=iargc()
  if(nargs.lt.2) then
     print*,'Usage: fmtiq <kHz> <offset> <nrpt>'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) nkhz
  call getarg(2,arg)
  read(arg,*) noffset
  nrpt=9999999
  if(nargs.ge.3) then
     call getarg(3,arg)
     read(arg,*) nrpt
  endif

  cmnd='rigctl -m 214 -r COM1 -s 4800 -C data_bits=8 -C stop_bits=2 -C serial_handshake=Hardware F 3592607'

  nHz=1000*nkhz - noffset
  write(cmnd(92:),*) nHz
  iret=system(cmnd)
  if(iret.ne.0) then
     print*,'Error setting TS-2000 frequency:'
     print*,cmnd
     go to 999
  endif

  open(13,file='fmt.out',status='unknown',position='append')
  open(14,file='fmt.spec',status='unknown',position='append')
  open(15,file='fmt.raw',status='unknown',position='append',    &
       form='unformatted')

  call soundinit
  ndevin=0
  iqmode=1
  df=48000.0/NFFT
  do iter=1,nrpt
     cmnd='rigctl -m 2509 -r USB F 3592607'
     nHz=1000*nkhz - noffset
     write(cmnd(25:),*) nHz + iter - 1
     iret=system(cmnd)
     if(iret.ne.0) then
        print*,'Error setting SoftRock frequency:'
        print*,cmnd
        go to 999
     endif

     nsec=time()
     ierr=soundin(ndevin,48000,iwave,NFFT,iqmode)
     if(ierr.ne.0) then
        print*,'Error in soundin',ierr
        stop
     endif

     sq=0.
     do i=1,NFFT
        x=iwave(1,i)
        y=iwave(2,i)
        c(i-1)=cmplx(y,x)
        sq=sq + x*x + y*y
     enddo

     rms=sqrt(sq/(2.0*NFFT))

     call four2a(c,NFFT,1,-1,1)

     smax=0.
     nz=NFFT/2
!     ia=1400.0/df
!     ib=1600.0/df
     ia=10/df
     ib=nz
     fac=100./float(nfft)**2
     do i=ia,ib
        s=fac * (real(c(i))**2 + aimag(c(i))**2)
        s1(i)=s
        if(abs(i*df-noffset).le.100.0) then
           if(s.gt.smax) then
              smax=s
              ipk=i
           endif
        endif
     enddo

     fpeak=ipk*df
     n=mod(nsec,86400)
     nhr=n/3600
     nmin=mod(n/60,60)
     nsec=mod(n,60)
!     smax=100.0*smax/(rms*rms)
     ave=0.
     diff=fpeak-noffset + iter - 1
     write(*,1100)  nhr,nmin,nsec,nkhz,noffset,fpeak,diff,smax,rms
     write(13,1100) nhr,nmin,nsec,nkhz,noffset,fpeak,diff,smax,rms
1100 format(i2.2,':',i2.2,':',i2.2,i7,i6,4f10.2)
!     write(14,1100) nhr,nmin,nsec,nkhz,noffset,fpeak,smax,ave,rms
     do i=ia,ib
        write(14,1102) i*df,s1(i)
1102    format(2f12.3)
     enddo
!     write(15) nhr,nmin,nsec,nkhz,noffset,fpeak,smax,ave,rms,iwave
     call flush(13)
!     call flush(14)
!     call flush(15)
  enddo

999 end program fmtiq

