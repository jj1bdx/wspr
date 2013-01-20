subroutine clean(xx,ipk,dtmin,dtmax,dbmin,snr,delay,nwwv,nd)

  parameter (NFSMAX=48000)
  real xx(NFSMAX)                             !Dirty profile
  real xt(NFSMAX)                             !Working profile
  real w1(NFSMAX/200)                         !Waveform of WWV tick
  real w2(NFSMAX/200)                         !Waveform of WWVH tick
  real ccf1(0:NFSMAX/6),ccf2(0:NFSMAX/6)
  real sq1(0:NFSMAX/6),sq2(0:NFSMAX/6),tmp(0:NFSMAX/6)
  real delay(4)
  real snr(4)
  integer nwwv(4)
  logical first
  data first/.true./
  save first,w1,w2

  nfs=48000
  ip=nfs
  dt=1.0/nfs
  gamma=1.0
  nd=0
  if(first) then
     do i=1,nfs/200
        w1(i)=sin(6.283185307*1000.0*dt*i)      !WWV tick waveform
        w2(i)=sin(6.283185307*1200.0*dt*i)      !WWVH tick waveform
     enddo
     first=.false.
  endif

  do i=1,ip
     j=ipk+i-1
     if(j.gt.ip) j=j-ip
     xt(i)=xx(j)
  enddo

  lag1=0.001*dtmin*nfs
  lagmax=0.001*dtmax*nfs

  do ii=1,4
     ccf1=0.
     ccf2=0.
     ccfmax=0.
     do lag=lag1,lagmax
        s1=0.
        s2=0.
        do i=1,nfs/200
           j=lag+i-1
           s1=s1 + w1(i)*xt(j)
           s2=s2 + w2(i)*xt(j)
        enddo

        ccf1(lag)=s1
        ccf2(lag)=s2

        if(s1.gt.ccfmax) then
           ccfmax=s1
           lagpk=lag
           nw=1
        endif
        if(s2.gt.ccfmax) then
           ccfmax=s2
           lagpk=lag
           nw=2
        endif
     enddo

     iz=lagmax-lag1+1
     do i=1,iz
        sq1(i)=abs(ccf1(i+lag1-1))
        sq2(i)=abs(ccf2(i+lag1-1))
     enddo
     call pctile(sq1,tmp,iz,50,rms1a)
     call pctile(sq2,tmp,iz,50,rms2a)

     fac=gamma*ccfmax/120.0
     if(nw.eq.1) then
        xt(lagpk:lagpk+239)=xt(lagpk:lagpk+239)-fac*w1
        snr0=ccfmax/rms1a
     else
        xt(lagpk:lagpk+239)=xt(lagpk:lagpk+239)-fac*w2
        snr0=ccfmax/rms2a
     endif

     snrdb=db(snr0/8.0)
     if(ii.eq.1) ccfmax0=ccfmax
     if(snrdb.lt.dbmin .or. ccfmax.lt.0.2*ccfmax0) go to 100
     nd=nd+1
     snr(nd)=snrdb
     delay(nd)=1000.0*lagpk*dt
     nwwv(nd)=nw
  enddo

100 continue

  return
end subroutine clean
