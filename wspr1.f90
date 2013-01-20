subroutine wspr1

  integer th_wspr2

  include 'acom1.f90'

! Start a thread for acquiring audio data
  ierr=th_wspr2()
  if(ierr.ne.0) then
     print*,'Error creating thread for wspr2',ierr
     stop
  endif

  return
end subroutine wspr1
