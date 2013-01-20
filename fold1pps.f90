subroutine fold1pps(x,npts,ip1,ip2,prof,p,pk,ipk)

  parameter (NFSMAX=48000)
  real x(npts)
  real proftmp(NFSMAX+5),prof(NFSMAX+5)
  real*8 p,ptmp

  pk=0.
  do ip=ip1,ip2
     call ffa(x,npts,npts,ip,proftmp,ptmp,pktmp,ipktmp)
     if(abs(pktmp).gt.abs(pk)) then
        p=ptmp
        pk=pktmp
        ipk=ipktmp
        prof(:ip)=proftmp(:ip)
     endif
  enddo
  ip=p
  if(pk.lt.0.0) then
     prof(:ip)=-prof(:ip)
  endif

  return
end subroutine fold1pps
