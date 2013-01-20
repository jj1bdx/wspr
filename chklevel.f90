subroutine chklevel(kwave,ntrminutes,iz,jz,nsec1,xdb1,xdb2,i4)

! Called from wspr2 at ~5 Hz rate.

  integer*2 kwave(iz,jz)
  integer time
  data nsec3z/-999/
  save nsec3z

  nfsample=48000
  if(ntrminutes.eq.15) nfsample=12000
  nsec3=time()
  i2=nfsample*(nsec3-nsec1)
  if(i2.gt.jz) i2=jz
  i1=max(1,i2-nfsample+1)
  do i=i2,i1,-1
     if(kwave(1,i).ne.0) go to 10
  enddo

10 i4=i
  tc=0.2                                  !Level-meter time constant (s)
  ii=nint(tc*nfsample)
  i3=max(1,i4-ii+1)
  if(nsec3.eq.nsec3z) go to 900

  nsec3z=nsec3
  npts=i4-i3+1
  s1=0.
  s2=0.
  do i=i3,i4
     s1=s1+kwave(1,i)
     if(iz.eq.2) s2=s2+kwave(2,i)
  enddo
  ave1=s1/npts
  ave2=s2/npts
  sq1=0.
  sq2=0.
  do i=i3,i4
     x1=kwave(1,i)-ave1
     sq1=sq1 + x1*x1
     if(iz.eq.2) then
        x2=kwave(2,i)-ave2
        sq2=sq2 + x2*x2
     endif
  enddo

  if(sq1.gt.0.0) then
     rms1=sqrt(sq1/npts)
     xdb1=20.0*log10(rms1)
  endif

  if(sq2.gt.0.0) then
     rms2=sqrt(sq2/npts)
     xdb2=20.0*log10(rms2)
  endif

900 continue

  return
end subroutine chklevel
