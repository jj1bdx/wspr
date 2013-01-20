subroutine mix162(id,npts,nbfo,c2,jz,ps)

! Mix from "nbfo" +/- 100 Hz to baseband, and downsample by 1/32

  parameter (NFFT1MAX=16*1024*1024)
  parameter (NH1MAX=NFFT1MAX/2)
  integer*2 id(npts)
  real x(NFFT1MAX)
  real ps(-256:256)
  real*8 df,fbfo
  complex c(0:NH1MAX)
  complex c2(0:65535)
  equivalence (x,c)

  nfft1=NFFT1MAX
  if(npts.le.120*12000) nfft1=2*1024*1024
  nfft2=65536
  nh2=nfft2/2
  ndown=nfft1/nfft2

! Load data into real array x; pad with zeros up to nfft.
  fac=1.e-4
  do i=1,npts
     x(i)=fac*id(i)
  enddo
  x(npts+1:nfft1)=0.

  call xfft(x,nfft1)                         !Do the real-to-complex FFT

  df=12000.d0/nfft1
  fbfo=nbfo
  if(npts.gt.120*12000) fbfo=nbfo + 112.5d0
  i0=nint(fbfo/df)
  ia=i0-NH2 + 1
  ib=i0+NH2

  k=-257
  do i=ia-64,ib,128
     k=k+1
     sq=0.
     do n=0,127
        sq=sq + real(c(i+n))**2 + aimag(c(i+n))**2
     enddo
     ps(k)=4.085e-8*sq
  enddo

  do i=0,NFFT2-1
     j=i0 + i
     if(i.gt.NH2) j=j-NFFT2
     c2(i)=c(j)
  enddo

  call four2a(c2,NFFT2,1,1,1)        !Return to time domain

  fac=1.e-5
  jz=npts/ndown
  do i=0,jz-1
     c2(i)=fac*c2(i)
  enddo

  return
end subroutine mix162
