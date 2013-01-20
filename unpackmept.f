      subroutine unpackmept(dat,msg)

C  Unpack 50 bits to retrieve an MEPT_JT message.

      parameter (NBASE=37*36*10*27*27*27)
      integer dat(12)
      character c1*12,grid*4,msg*22,grid6*6

      nc1=ishft(dat(1),22) + ishft(dat(2),16) + ishft(dat(3),10)+
     +  ishft(dat(4),4) + iand(ishft(dat(5),-2),15)

      n2=ishft(iand(dat(5),3),26) + ishft(dat(6),20) + 
     +  ishft(dat(7),14) + ishft(dat(8),8) + ishft(dat(9),2) + 
     +  iand(ishft(dat(10),-4),3)

      ng=n2/128
      ndbm=iand(n2,127) - 64

      if(nc1.lt.NBASE) then
         call unpackcall(nc1,c1)
      else
         print*,'Error in unpackmept: bad callsign?'
         stop
      endif

      call unpackgrid(ng,grid)
      grid6=grid//'ma'
      call grid2k(grid6,k)
      if(k.ge.1 .and. k.le.900)  then
         print*,'Error in unpackmept: k=',k
         stop
      endif

      i=index(c1,char(0))
      if(i.ge.3) c1=c1(1:i-1)//'            '

      msg='                      '
      j=0
      do i=1,12
         j=j+1
         msg(j:j)=c1(i:i)
         if(c1(i:i).eq.' ') go to 10
      enddo
      j=j+1
      msg(j:j)=' '

 10   if(k.eq.0) then
         do i=1,4
            if(j.le.21) j=j+1
            msg(j:j)=grid(i:i)
         enddo
         j=j+1
         msg(j:j)=' '
      endif

 100  return
      end
