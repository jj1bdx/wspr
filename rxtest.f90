program rxtest

  character*22 message
  character*11 datetime
  character*12 arg
  real*8 freq
  real a(5)
  complex c3(45000),c4(45000)
  complex c(65536)

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: rxtest <ifile>'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) ireq

  dt=1.0/375
  jz=45000
  ngood=0
  do ifile=1,9999
     read(71,end=900),datetime,nsnrx,dtx,freq,nf1,c3
     if(ifile.ne.ireq .and. ireq.ne.0) go to 24

     do idt=0,128
        ii=(idt+1)/2
        if(mod(idt,2).eq.1) ii=-ii
        i1=nint((dtx+2.0)/dt) + ii !Start index for synced symbols
        if(i1.ge.1) then
           i2=i1 + jz - 1
           c4(1:jz)=c3(i1:i2)
        else if(i1.eq.0) then
           c4(1)=0.
           c4(2:jz)=c3(jz-1)
        else
           c4(:-i1+1)=0
           i2=jz+i1
           c4(-i1:)=c3(:i2)
        endif
!        if(idt.eq.0) call afc2(c4)
!        call afc2(c4)
        call decode162(c4,jz,message,ncycles,metric,nerr)
        if(message(1:6).ne.'      ') then
           write(*,1012) ifile,nsnrx,dtx,freq,nf1,message,ii
1012       format(i4.4,i4,f5.1,f11.6,i3,2x,a22,i5)
           ngood=ngood+1
           go to 24
        endif
     enddo
24   continue
  enddo

900 if(ireq.eq.0) write(*,1024) ngood
1024 format('ngood:',i5)
  
999 end program rxtest
