subroutine loggit(msg)
  character*(*) msg
  character*20 m20
  real*8 tsec1,trseconds
  integer nt(9)
  include 'acom1.f90'

  call cs_lock('loggit')
  call gmtime2(nt,tsec1)
  trseconds=60*ntrminutes
  sectr=mod(tsec1,trseconds)
  m20=msg//'                    '
  write(19,1000) cdate(3:8),utctime(1:2),utctime(3:4),utctime(5:10),sectr,m20
1000 format(a6,1x,a2,':',a2,':',a5,f8.2,2x,a20)
  call flush(19)
  call cs_unlock

  return
end subroutine loggit
