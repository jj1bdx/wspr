subroutine xcor162(s2,ipk,nsteps,nsym,lag1,lag2,ccf,ccf0,lagpk)

!  Computes ccf of a row of s2 and the pseudo-random array pr3.  Returns
!  peak of the CCF and the lag at which peak occurs.  

  parameter (NFFT=512)
  parameter (NH=NFFT/2)
  parameter (NSMAX=352)
  real s2(-NH:NH,NSMAX)
  real a(NSMAX)
  real ccf(-5:540)
  logical first
  data first/.true./
  integer npr3(162)
  real pr3(162)
  data npr3/                                                              &
       & 1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,                         &
       & 0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,                         &
       & 0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,                         &
       & 1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,                         &
       & 0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,                         &
       & 0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,                         &
       & 0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,                         &
       & 0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,                         &
       & 0,0/
  save

  if(first) then
     nsym=162
     do i=1,nsym
        pr3(i)=2*npr3(i)-1
     enddo
     first=.false.
  endif

  n=2
  method=2
  do j=1,nsteps
     if(method.eq.1) then
        a(j)=0.5*(s2(ipk+n,j) + s2(ipk+3*n,j) -                      &
             &       s2(ipk  ,j) - s2(ipk+2*n,j))
     else
        a(j)=max(s2(ipk+n,j),s2(ipk+3*n,j)) -                        &
             &          max(s2(ipk  ,j),s2(ipk+2*n,j))
     endif
  enddo

  ccfmax=0.
  do lag=lag1,lag2
     x=0.
     do i=1,nsym
        j=2*i-1+lag
        if(j.ge.1 .and. j.le.nsteps) x=x+a(j)*pr3(i)
     enddo
     ccf(lag)=2*x                        !The 2 is for plotting scale
     if(ccf(lag).gt.ccfmax) then
        ccfmax=ccf(lag)
        lagpk=lag
     endif
  enddo
  ccf0=ccfmax

  return
end subroutine xcor162
