subroutine genmept(message,ntxdf,ntrminutes,multi,list,snrdb,iwave)

! Encode a WSPR message and generate the corresponding wavefile.

  character*22 message
  parameter (NMAX=900*12000)     !Max length of wave file
  integer*2 iwave(NMAX)          !Generated wave file
  parameter (MAXSYM=176)
  integer*1 symbol(MAXSYM)
  integer*1 data0(11),i1
  integer npr3(162)
  logical first
  real*8 t,dt,phi,f,f0,dfgen,dphi,pi,twopi,tsymbol
  equivalence(i1,i4)
  data npr3/                                    &
      1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,  &
      0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,  &
      0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,  &
      1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,  &
      0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,  &
      0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,  &
      0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,  &
      0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,  &
      0,0/

  data first/.true./,idum/0/
  save

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

! Set up necessary constants
  tsymbol=8192.d0/12000.d0
  if(ntrminutes.eq.15) tsymbol=65536.d0/12000.d0
  nz=60*ntrminutes*12000
  dt=1.d0/12000.d0
  f0=1500 + ntxdf
  dfgen=1.d0/tsymbol                          !1.4649 Hz or 0.1831 Hz
  nsigs=1
  if(multi.ne.0) nsigs=10
  do isig=1,nsigs
     if(nsigs.eq.1) snr=10.0**(0.05*snrdb)
     fac=3000.0
     if(snr.gt.1.0) fac=3000.0/snr
     t=-2.d0 - 0.1*(isig-1)
     if(nsigs.eq.10) then
        if(ntrminutes.eq.2) then
           ndb=-20-isig
           snr=10.0**(0.05*ndb)
           f0=1390 + 20*isig
        else
           ndb=-29-isig
           snr=10.0**(0.05*ndb)
           f0=1612.5 + 2.5*(isig-5.5)
        endif
        dtx=-t-2.0
        write(*,1000) isig,ndb,dtx,1.d-6*f0,message
1000    format(i2,2x,i4,f5.1,f11.6,2x,a22)
     endif

     phi=0.d0
     j0=0

     do i=1,nz
        t=t+dt
        j=int(t/tsymbol) + 1                          !Symbol number
        sig=0.
        if(j.ge.1 .and. j.le.162) then
           if(j.ne.j0) then
              f=f0 + dfgen*(npr3(j)+2*symbol(j)-1.5)
              j0=j
              if(list.ne.0) then
                 k=npr3(j) + 2*symbol(j)
                 write(*,1010) j,k,f
1010             format(i3,i3,f10.3)
                 go to 10
              else
                 dphi=twopi*dt*f
              endif
           endif
           sig=0.9999
        endif
        phi=phi+dphi
        if(snrdb.gt.50.0) then
           n=32767.0*sin(phi)           !Normal transmission, signal only
        else
           if(isig.eq.1) then
              n=fac*(gran(idum) + sig*snr*sin(phi))
           else
              n=iwave(i) + fac*sig*snr*sin(phi)
           endif
           if(n.gt.32767) n=32767
           if(n.lt.-32767) n=-32767
        endif
        iwave(i)=n
10      continue
     enddo
  enddo

  return
end subroutine genmept
