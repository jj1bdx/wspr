subroutine phasetx(id2,npts,txbal,txpha)

  integer*2 id2(2,npts)

  pha=txpha/57.2957795
  xbal=10.0**(0.005*txbal)
  if(xbal.gt.1.0) then
     b1=1.0
     b2=1.0/xbal
  else
     b1=xbal
     b2=1.0
  endif
  do i=1,npts
     x=id2(1,i)
     y=id2(2,i)
     amp=sqrt(x*x+y*y)
     phi=atan2(y,x)
     id2(1,i)=nint(b1*amp*cos(phi))
     id2(2,i)=nint(b2*amp*sin(phi+pha))
  enddo

  return
end subroutine phasetx
