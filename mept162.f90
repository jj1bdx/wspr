subroutine mept162(outfile,appdir,nappdir,f0,ncmdline,id,npts,nbfo,ierr)

! Orchestrates the process of finding, synchronizing, and decoding 
! WSPR signals.

  integer*2 id(npts)
  character*22 message
  character*80 outfile,appdir,alltxt
  character*11 datetime
  character cdate*8,ctime*10
  real*8 f0,freq,tsec
  real ps(-256:256)
  real sstf(5,275)
  real a(5)
  complex c2(65536)
  complex c3(45000),c4(45000)

! WSPR-2: mix from nbfo +/- 100 Hz to baseband, downsample by 1/32
! WSPR-15: mix from (nbfo+112.5) +/- 12.5 Hz to baseband, downsample by 1/256
  call mix162(id,npts,nbfo,c2,jz,ps)
  c2(jz+1:)=0.
  jz=45000
  if(ncmdline.eq.0) then
     call spec162(c2,jz,appdir,nappdir)              !Compute pixmap.dat
  endif

  call sync162(c2,jz,ps,sstf,kz)        !Look for sync patterns, get DF and DT

  ierr = 0
  if(kz.eq.0) go to 900
  if (kz.gt.275 .or. kz.lt.0) then
     call getutc(cdate,ctime,tsec)

     call cs_lock('mept162')
     write(*,1000) ctime,kz
1000 format('Time ',a8,'. Error from sync162: kz is',i10)
     call cs_unlock

     ierr = 1
     return
  endif
  do k=1,kz
     snrsync=sstf(1,k)
     snrx=sstf(2,k)
     dtx=sstf(3,k)
     dfx=sstf(4,k)
     drift=sstf(5,k)
     a(1)=-dfx
     a(2)=-0.5*drift
     a(3)=0.
     call twkfreq(c2,c3,jz,a)                    !Remove drift

     minsync=1                                   !####
     nsync=nint(snrsync)
     if(nsync.lt.0) nsync=0
     if(npts.le.120*12000) then
        minsnr=-33
        nsnrx=nint(snrx)                         !WSPR-2
        if(nsnrx.lt.minsnr) nsnrx=minsnr
        freq=f0 + 1.d-6*(dfx+nbfo)
     else
        minsnr=-42
        nsnrx=nint(snrx-9.0)                     !WSPR-15
        if(nsnrx.lt.minsnr) nsnrx=minsnr
        dfx=dfx/8
        freq=f0 + 1.d-6*(dfx+nbfo+112.5d0)
     endif
     message='                      '
     if(nsync.ge.minsync .and. nsnrx.ge.minsnr) then
        dt=1.0/375
        do idt=0,128
           ii=(idt+1)/2
           if(mod(idt,2).eq.1) ii=-ii
           i1=nint((dtx+2.0)/dt) + ii !Start index for synced symbols
           if(i1.ge.1) then
!  Fix this earlier!
              c4(1:jz-i1+1)=c3(i1:)
              c4(jz-i1+2:)=0.
           else
              c4(:-i1+1)=0.
              c4(-i1+2:jz)=c3(:i1+jz-1)
              if(jz.lt.45000) c4(jz:)=0.
           endif
           call decode162(c4,45000,message,ncycles,metric,nerr)
           if(message(1:6).ne.'      ' .and.                        &
                message(1:6).ne.'000AAA' .and.                      &
                index(message,'A000AA').le.0) go to 23
        enddo
        go to 24

23      i2=index(outfile,'.wav')-1
        if(i2.le.0) i2=index(outfile,'.WAV')-1
        datetime=outfile(max(1,i2-10):i2)
        datetime(7:7)=' '
        nf1=nint(-a(2))
        alltxt=appdir(:nappdir)//'/ALL_WSPR.TXT'
        if(npts.gt.120*12000) dtx=8*(dtx + 1.8)    !### The 1.8 is empirical ###

        call cs_lock('mept162a')
        if(ncmdline.eq.0) then
           open(13,file=alltxt,status='unknown',position='append')
           write(13,1010) datetime,nsync,nsnrx,dtx,freq,message,nf1,   &
                ncycles/81,ii
           close(13)
        else
           write(*,1008) datetime(8:11),nsnrx,dtx,freq,message
1008       format(a4,i4,f5.1,f11.6,2x,a22)
        endif
        write(14,1010) datetime,nsync,nsnrx,dtx,freq,message,nf1,      &
             ncycles/81,ii
1010    format(a11,i4,i4,f5.1,f11.6,2x,a22,i3,i6,i5)
        call flush(14)
        i1=index(message,' ')
        call cs_unlock

     endif
24   continue
  enddo

900 return
end subroutine mept162
