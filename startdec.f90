subroutine startdec

  integer th_decode
  external decode
  include 'acom1.f90'

  ierr=th_decode()
  if(ierr.ne.0) then
     print*,'Error starting decode thread',ierr
     stop
  endif

  return
end subroutine startdec
