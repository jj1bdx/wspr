subroutine starttx

  integer th_tx

  include 'acom1.f90'

  ierr=th_tx()
  if(ierr.ne.0) then
     print*,'Error starting tx thread',ierr
     stop
  endif

  return
end subroutine starttx
