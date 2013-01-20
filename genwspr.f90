subroutine genwspr(message,ntxdf,ntune,snrdb,iqmode,iqtx,ntrminutes,   &
     appdir,nappdir,msg2,jwave)

! Encode an MEPT_JT message and generate the corresponding wavefile.

!  parameter (NMAX=2*120*48000)     !Max length of wave file
  parameter (NMAX=900*48000)    !Max length of wave file (no IQ mode in WSPR-15)
  character*22 message           !Message to be generated
  character*22 msg2
  character*80 appdir,alltxt
  integer*2 jwave(NMAX)          !Generated wave file
  parameter (MAXSYM=176)
  integer*1 symbol(MAXSYM)
  integer*1 data0(11),i1
  integer npr3(162)
  logical first
  real*8 t,dt,phi,f,f0,dfgen,dphi,pi,twopi,tsymbol
  include 'acom2.f90'

  equivalence(i1,i4)
  data npr3/                                   &
    1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,   &
    0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,   &
    0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,   &
    1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,   &
    0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,   &
    0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,   &
    0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,   &
    0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,   &
    0,0/

  data first/.true./,idum/0/
  save first,idum,pi,twopi

  if(first) then
     pi=4.d0*atan(1.d0)
     twopi=2.d0*pi
     first=.false.
  endif

  call wqencode(message,ntype,data0)
  nbytes=(50+31+7)/8
  call encode232(data0,nbytes,symbol,MAXSYM)  !Convolutional encoding
  call inter_mept(symbol,1)                   !Apply interleaving
  do i=1,162
     i4=0
     i1=symbol(i)
  enddo
  call wqdecode(data0,msg2,ntype2)

! Set up necessary constants
  nsps=8192
  if(ntrminutes.eq.15) nsps=65536
  tsymbol=4.d0*nsps/48000.d0
  dt=1.d0/48000.d0
  f0=1500 + ntxdf
  dfgen=1.d0/tsymbol                 !1.4649 Hz in WSPR-2, 0.1831 Hz in WSPR-15
  snr=10.0**(0.05*(snrdb-6.5))       !Bandwidth correction?
  fac=3000.0
  if(snr.gt.1.0) fac=3000.0/snr
  t=-1.d0
  phi=0.d0
  j0=0
  f=f0
  dphi=twopi*dt*f
  
  do i=1,ntrminutes*60*48000
     t=t+dt
     j=int(t/tsymbol) + 1                          !Symbol number
     sig=0.
     if(j.ge.1 .and. j.le.162) then
        if(j.ne.j0 .and. ntune2.eq.0) then
           f=f0 + dfgen*(npr3(j)+2*symbol(j)-1.5)
           j0=j
           dphi=twopi*dt*f
        endif
        sig=0.9999
        phi=phi+dphi
        if(snrdb.gt.50.0) then
           if(iqmode.eq.0) then
              n=32767.0*sin(phi)           !Normal transmission, signal only
              jwave(i)=n
           else
              n1=32767.0*cos(phi)           !Normal transmission, signal only
              n2=32767.0*sin(phi)           !Normal transmission, signal only
              if(iqtx.eq.0) then
                 jwave(2*i-1)=n1
                 jwave(2*i)=n2
              else
                 jwave(2*i-1)=n2
                 jwave(2*i)=n1
              endif
           endif
        else
           if(iqmode.eq.0) then
              n=fac*(gran(idum) + sig*snr*sin(phi))
              if(n.gt.32767) n=32767
              if(n.lt.-32767) n=-32767
              jwave(i)=n
           else
              n=fac*(gran(idum) + sig*snr*cos(phi))
              if(n.gt.32767) n=32767
              if(n.lt.-32767) n=-32767
              jwave(2*i-1)=n
              n=fac*(gran(idum) + sig*snr*sin(phi))
              if(n.gt.32767) n=32767
              if(n.lt.-32767) n=-32767
              jwave(2*i)=n
           endif
        endif
     else
        if(iqmode.eq.0) then
           jwave(i)=0
        else
           jwave(2*i-1)=0
           jwave(2*i)=0
        endif
     endif
  enddo
  if(ntune2.lt.0) msg2='Tune'
  if(ntune2.eq.-3) msg2='ATU tuneup'
  ntune2=0

  return
end subroutine genwspr
