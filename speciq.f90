subroutine speciq(kwave,npts,iwrite,iqrx,nfiq,ireset,gain,phase,reject)

  parameter (NFFT=32768)
  parameter (NH=NFFT/2)
  integer*2 kwave(2,npts)
  real s(-NH+1:NH)
  complex c,z,zsum,zave
  complex c0
  complex h,u,v
  common/fftcom2/c(0:NFFT-1),c0(0:NFFT-1)
  data iw0/-999/
  save

  if(ireset.eq.1) then
     nn=0
     zsum=0.
     ireset=0
     rsum=0.
  endif

  df=48000.0/NFFT

  if(iwrite.lt.nfft .or. iwrite.eq.iw0) go to 900
  iw0=iwrite
  nn=nn+1
  fac=10.0**(-4.3)
  j=iwrite-nfft
  do i=0,nfft-1
     j=j+1
     if(iqrx.eq.0) then
        x=kwave(2,j)
        y=kwave(1,j)
     else
        x=kwave(1,j)
        y=kwave(2,j)
     endif
     c(i)=fac*cmplx(x,y)
  enddo
  c0=c

  call four2a(c,NFFT,1,-1,1)              ! 1d, forward, complex

  smax=0.
  ia=(nfiq+500)/df
  ib=(nfiq+2500)/df
  ipk=0
  do i=0,nfft-1
     j=i
     if(j.gt.NH) j=j-nfft
     s(j)=real(c(i))**2 + aimag(c(i))**2
     if(i.ge.ia .and. i.le.ib .and. s(j).gt.smax) then
        smax=s(j)
        ipk=i
     endif
  enddo
  
  if(ipk.eq.0) then
     print*,'b',ia,ib,ipk,iwrite
     go to 900
  endif

  p=s(ipk) + s(-ipk)
  z=c(ipk)*c(nfft-ipk)/p
  zsum=zsum+z
  zave=zsum/nn
  tmp=sqrt(1.0 - (2.0*real(zave))**2)
  phase=asin(2.0*aimag(zave)/tmp)
  gain=tmp/(1.0-2.0*real(zave))
  h=gain*cmplx(cos(phase),sin(phase))

  u=c(ipk)
  v=c(nfft-ipk)
  x=real(u)  + real(v)  - (aimag(u) + aimag(v))*aimag(h) +              &
       (real(u) - real(v))*real(h)
  y=aimag(u) - aimag(v) + (aimag(u) + aimag(v))*real(h)  +              &
       (real(u) - real(v))*aimag(h)
  p1=x*x + y*y

  u=c(nfft-ipk)
  v=c(ipk)
  x=real(u)  + real(v)  - (aimag(u) + aimag(v))*aimag(h) +              &
       (real(u) - real(v))*real(h)
  y=aimag(u) - aimag(v) + (aimag(u) + aimag(v))*real(h)  +              &
       (real(u) - real(v))*aimag(h)
  p2=x*x + y*y

  r=db(p1/p2)
  if(nn.ge.2) then
     rsum=rsum+r
     reject=rsum/(nn-1)
  endif

900 return
end subroutine speciq
