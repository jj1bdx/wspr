subroutine ffa(dat,ndim,npts,ip,prof,pmax,pk,ipk)

! Copyright (C) 1995 by Peter Mueller, MPIfR.   peter@mpifr-bonn.mpg.de
!
! Permission to use, copy, modify, and distribute this software and its
! documentation for any purpose and without fee is hereby granted, provided
! that the above copyright notice appear in all copies and that both that
! copyright notice and this permission notice appear in supporting
! documentation.  This software is provided "as is" without express or
! implied warranty.

!     dat(1:npts)           Raw data
!     ip                    Period is between ip and ip+1
!     prof(1:ip)            Folded profile   
!     pmax                  Best period
!     xmax                  Peak of profile

  implicit real*4 (a-h,o-z)
  real puls(NDIM)
  real prof(*)
  real*8 p,p1,p2,p3,p4,p5,ps,dp,pmax
  real*4 x,xp,xmax,xmax0,xmax1
  real dat(NDIM)

  xmax=-1.e30
  nmax=ip*2**int(log(float(npts)/float(ip))/log(2.0) + 0.95)
  if(nmax .gt. NDIM) nmax=nmax/2
 
  lmax=nmax/(ip +1)
  kp=nint(log(lmax+1.0)/log(2.0))
  dp=dfloat(ip+1)/dfloat(nmax)
  p1=1.d0/dfloat(ip)
  p2=p1*p1
  p3=p2*p1
  p4=p3*p1
  p5=p4*p1
  ps=p1+p2+p3+p4+p5

  do n=0, lmax-1
     x=dp*n
     xp=(((((p5*x + p4)*x + p3)*x + p2)* x - ps)*x + p1)*x
     p=ip+x-xp
     do nn=0,kp-1
        if(mod(n,2**nn) .eq. 0) kp1=kp-nn 
     enddo
     do k=kp1,kp
        np=2**(kp-k)
        joff=nmax - nmax/2**(k-1)
        ioff=nmax - nmax/2**max(k-2,0)
        ish=mod((n+np) / np / 2, ip)
        do i=0,np-1
           iip=i*ip
           i0=iip+joff
           i1=2*iip + ioff
           i2=i1+ip
           do j=1,ip
              j1=j+ish
              if(j1.gt.ip) j1=j1-ip
              ind=j+i0
              jnd=j+i1
              knd=j1+i2
              if(kp1.eq.1 .and. k.eq.1) then
                 puls(ind)=dat(jnd) + dat(knd)
              else
                 puls(ind)=puls(jnd) + puls(knd)
              endif
           enddo
        enddo
     enddo
     
     xmax1=xmax
     xmax0=-1.e30
     do j=1,ip
        pp=puls(j+joff)
        pp=abs(pp)                          !JHT (for hftoa)
        xmax0=max(pp,xmax0)
     enddo
     xmax=max(xmax0,xmax)

!     write(22,3001) p,xmax0/lmax
!3001 format(2f12.6)

     if(xmax.gt.xmax1) then
        pmax=p
        do j=1,ip
           prof(j)=puls(j+joff)/lmax
        enddo
     endif
  enddo

  pk=0.
  do i=1,ip
     if(abs(prof(i)).gt.abs(pk)) then
        pk=prof(i)
        ipk=i
     endif
  enddo
         
  return
end subroutine ffa
