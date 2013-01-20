subroutine iqdemod(kwave,npts,nfiq,nbfo,iqrx,iqrxapp,gain,phase,iwave)

! Convert I/Q data sampled at 48000 Hz to real data sampled at 12000 Hz.

  parameter (NFFT =5760000)
  parameter (NFFT4=1440000)
  integer*2 kwave(2,114*48000)
  integer*2 iwave(114*12000)
  real*8 df,f0,sq
  real x1(NFFT4)
  complex c,c1
  complex h,u,v
  common/fftcom/ c(0:NFFT-1),c1(0:NFFT4-1)
  equivalence (x1,c1)

  df=48000.d0/NFFT
  f0=nfiq
  do i=1,npts
     if(iqrx.eq.0) then
        x=kwave(2,i)
        y=kwave(1,i)
     else
        x=kwave(1,i)
        y=kwave(2,i)
     endif
     c(i-1)=cmplx(x,y)
  enddo
  c(npts:)=0.

  call four2a(c,NFFT,1,-1,1)               !Long FFT of entire I/Q dataset

  ia=nint(f0/df)
  ib=nint((f0+3000.d0)/df)
  j=-1
  fac=1.0/NFFT

  h=gain*cmplx(cos(phase),sin(phase))
  if(iqrxapp.eq.0) then
     do i=ia,ib
        j=j+1
        k=i
        if(k.lt.0) k=k+nfft
        c1(j)=fac*c(k)
     enddo
  else
     do i=ia,ib
        j=j+1
        k=i
        if(k.lt.0) k=k+nfft
        u=fac*c(k)
        v=fac*c(nfft-k)
        x=real(u)  + real(v)  - (aimag(u) + aimag(v))*aimag(h) +         &
             (real(u) - real(v))*real(h)
        y=aimag(u) - aimag(v) + (aimag(u) + aimag(v))*real(h)  +         &
             (real(u) - real(v))*aimag(h)
        c1(j)=cmplx(x,y)
     enddo
  endif

  c1(j+1:)=0.
  c1(0)=0.

  bw=3000.0
  if(bw.lt.3000.0) then
     ja=nint((nbfo-0.5*bw))/df
     jb=nint((nbfo+0.5*bw))/df
     c1(:ja-1)=0.
     c1(jb+1:)=0.
  endif

  call four2a(c1,NFFT4,1,1,-1)

  sq=0.
  do i=1,npts/4
     sq=sq + x1(i)**2
  enddo
  rms=sqrt(sq/(npts/4.0))

  fac=3000.0/rms
  do i=1,npts/4
     r=fac*x1(i)
     if(r.gt. 32767.0) r= 32767.0
     if(r.lt.-32767.0) r=-32767.0
     iwave(i)=nint(r)
  enddo

  return
end subroutine iqdemod
