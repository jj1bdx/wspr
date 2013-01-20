subroutine getrms(iwave,npts,ave,rms)

  integer*2 iwave(npts)
  real*8 sq

  s=0.
  do i=1,npts
     s=s + iwave(i)
  enddo
  ave=s/npts
  sq=0.
  do i=1,npts
     sq=sq + (iwave(i)-ave)**2
  enddo
  rms=sqrt(sq/npts)
  fac=3000.0/rms
  do i=1,npts
     n=nint(fac*(iwave(i)-ave))
     if(n.gt.32767) n=32767
     if(n.lt.-32767) n=-32767
     iwave(i)=n
  enddo

  return
end subroutine getrms
