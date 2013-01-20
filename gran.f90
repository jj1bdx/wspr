real function gran(newseed)

! Generate gaussian random numbers with rms=1.0.

  real r(0:31)
  data i1/0/,i2/0/
  save i1,i2,g1

  if(newseed.lt.0) then
     call random_seed
     newseed=0
  endif
  if (i1.eq.0) then
1    if(i2.eq.0) call random_number(r)
     v1=2.0*r(2*i2)   - 1.0
     v2=2.0*r(2*i2+1) - 1.0
     i2=iand(i2+1,15)
     sq=v1**2 + v2**2
     if(sq.ge.1..or.sq.eq.0.) go to 1
     fac=sqrt(-2.*log(sq)/sq)
     g1=v1*fac
     gran=v2*fac
     i1=1
  else
     gran=g1
     i1=0
  endif

  return
end function gran
