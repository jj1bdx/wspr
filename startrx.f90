subroutine startrx

  integer th_rx

  include 'acom1.f90'

  ierr=th_rx()
  if(ierr.ne.0) then
     print*,'Error starting rx thread',ierr
     stop
  endif

  return
end subroutine startrx
