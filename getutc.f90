subroutine getutc(cdate,ctime,tsec)

  character cdate*8,ctime*10
  real*8 tsec
  integer nt(9)
!        1    2    3    4     5    6    7    8   9
!  nt:  sec  min  ihr  day  month year dweek 0   0

  call gmtime2(nt,tsec)
  cdate(1:1)=char(48+nt(6)/1000)
  cdate(2:2)=char(48+mod(nt(6),1000)/100)
  cdate(3:3)=char(48+mod(nt(6),100)/10)
  cdate(4:4)=char(48+mod(nt(6),10))
  cdate(5:5)=char(48+nt(5)/10)
  cdate(6:6)=char(48+mod(nt(5),10))
  cdate(7:7)=char(48+nt(4)/10)
  cdate(8:8)=char(48+mod(nt(4),10))
  ctime(1:1)=char(48+nt(3)/10)
  ctime(2:2)=char(48+mod(nt(3),10))
  ctime(3:3)=char(48+nt(2)/10)
  ctime(4:4)=char(48+mod(nt(2),10))
  ctime(5:5)=char(48+nt(1)/10)
  ctime(6:6)=char(48+mod(nt(1),10))
  ctime(7:7)='.'
  nsec=tsec
  msec=1000*(tsec-nsec)
  ctime(8:8)=char(48+msec/100)
  ctime(9:9)=char(48+mod(msec,100)/10)
  ctime(10:10)=char(48+mod(msec,10))

  return
end subroutine getutc
