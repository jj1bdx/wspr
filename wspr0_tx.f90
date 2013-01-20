subroutine wspr0_tx(ntrminutes,nport,nfiles,multi,list,snrdb,f0,ftx,    &
     call12,grid6,ndbm,outfile,ntr)

!  Read command-line arguments and generate Tx data for the MEPT_JT mode.

  parameter (NMAX=900*12000)
  real*8 f0,ftx
  character*12 call12
  character*6 grid6
  character*3 cdbm
  character*22 message
  character*80 outfile
  integer*2 iwave(NMAX)
  integer ptt,soundout

  ntxdf=nint(1.d6*(ftx-f0))-1500
  txdf2=1.d6*(ftx-f0)-1612.5d0
  if(multi.eq.0 .and. list.eq.0) then
     if(ntrminutes.eq.2 .and. abs(ntxdf).gt.100) then
        print*,'Error: ftx must be above f0 by 1400 to 1600 Hz'
        stop
     else if(ntrminutes.eq.15 .and. abs(txdf2).gt.12.5) then
        print*,'Error: ftx must be above f0 by 1600 to 1625 Hz'
        stop
     endif
  endif

  i1=index(call12,' ')
  write(cdbm,'(i3)'),ndbm
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)

! Should allow for compound callsign and/or 6-digit locator
  message=call12(1:i1)//grid6(1:4)//' '//cdbm

  do ifile=1,nfiles
     if(nfiles.gt.1 .or. outfile(1:1).eq.' ') write(outfile,1010) ifile
1010 format(i5.5,'.wav')
     call genmept(message,ntxdf,ntrminutes,multi,list,snrdb,iwave)
     if(list.ne.0) go to 999
     if(outfile.ne."") then
        nz=60*ntrminutes*12000
        call wfile5(iwave,nz,12000,outfile)
        write(*,1020) f0,ftx,snrdb,message,outfile(1:24)
1020    format(2f11.6,f6.1,2x,a22,2x,a24)
     else
20      nsec=time()
        isec=mod(nsec,86400)
        ih=isec/3600
        im=(isec-ih*3600)/60
!        is=mod(isec,60)
        is120=mod(isec,120)
        if(is120.eq.0) then
           if(nport.gt.0) ierr=ptt(nport,junk,1,iptt)
!           if(ntr.eq.0) write(*,1030) ih,im,is,f0,ftx,message
!1030       format(i2.2,':',i2.2,':',i2.2,2f11.6,2x,a22)
           do i=22,1,-1
              if(message(i:i).ne.' ') go to 25
           enddo
25         iz=i
           write(*,1031) ih,im,ftx,message(1:iz)
1031       format(2i2.2,9x,f11.6,'  Transmitting "',a,'"')
           write(14,1032) ih,im,ftx,message(1:iz)
1032       format(7x,2i2.2,13x,f11.6,'  Transmitting "',a,'"')
           ierr=soundout(-1,12000,iwave,114*12000,0)
           if(nport.gt.0) ierr=ptt(nport,junk,0,iptt)
           if(ntr.ne.0) go to 999
        endif
        call msleep(100)
        go to 20
     endif
     if(nfiles.eq.9999) go to 999
  enddo

999 return
end subroutine wspr0_tx
