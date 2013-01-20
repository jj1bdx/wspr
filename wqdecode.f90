subroutine wqdecode(data0,message,ntype)

  parameter (N15=32768)
  integer*1 data0(11)
  character*22 message
  character*12 callsign
  character*3 cdbm
  character grid4*4,grid6*6
  logical first
  character*12 dcall(0:N15-1)
  data first/.true./
  save first,dcall

  call cs_lock('wqdecode')
! May want to have a timeout (say, one hour?) on calls fetched 
! from the hash table.

  if(first) then
     dcall='            '
     first=.false.
  endif

  message='                      '
  call unpack50(data0,n1,n2)
  call unpackcall(n1,callsign)
  i1=index(callsign,' ')
  call unpackgrid(n2/128,grid4)
  ntype=iand(n2,127) -64

! Standard WSPR message (types 0 3 7 10 13 17 ... 60)
  if(ntype.ge.0 .and. ntype.le.62) then
     nu=mod(ntype,10)
     if(nu.eq.0 .or. nu.eq.3 .or. nu.eq.7) then
        write(cdbm,'(i3)'),ntype
        if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
        if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
        message=callsign(1:i1)//grid4//' '//cdbm
        call hash(callsign,i1-1,ih)
        dcall(ih)=callsign(:i1)
     else
        nadd=nu
        if(nu.gt.3) nadd=nu-3
        if(nu.gt.7) nadd=nu-7
        ng=n2/128 + 32768*(nadd-1)
        call unpackpfx(ng,callsign)
        ndbm=ntype-nadd
        write(cdbm,'(i3)'),ndbm
        if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
        if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
        i2=index(callsign,' ')
        message=callsign(:i2)//cdbm
        call hash(callsign,i2-1,ih)
        dcall(ih)=callsign(:i2)
     endif
  else if(ntype.lt.0) then
     ndbm=-(ntype+1)
     grid6=callsign(6:6)//callsign(1:5)
     ih=(n2-ntype-64)/128
     callsign=dcall(ih)
     write(cdbm,'(i3)'),ndbm
     if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
     if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
     i2=index(callsign,' ')
     if(dcall(ih)(1:1).ne.' ') then
        message='<'//callsign(:i2-1)//'> '//grid6//' '//cdbm
     else
        message='<...> '//grid6//' '//cdbm
     endif
  endif
  call cs_unlock

  return
end subroutine wqdecode
