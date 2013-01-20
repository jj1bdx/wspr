subroutine averms(x,npts,ave,rms,xmax)

  real x(npts)

  s=0.
  xmax=0.
  do i=1,npts
     s=s + x(i)
     xmax=max(xmax,abs(x(i)))
  enddo
  ave=s/npts

  sq=0.
  do i=1,npts
     sq=sq + (x(i)-ave)**2
  enddo
  rms=sqrt(sq/(npts-1))
  
  return
end subroutine averms
