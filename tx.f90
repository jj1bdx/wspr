subroutine tx

!  Make one transmission of a WSPR message, or an unmodulated "Tune" sequence.

  integer system

  parameter (NMAX2=900*48000)
  parameter (NMAX3=4.5*48000)
  character message*22,message0*22,call1*12,cdbm*3
  character*22 msg0,msg1,cwmsg
  character crig*6,cbaud*6,cdata*1,cstop*1
  character cmnd*120,snrfile*80
  character*80 alltxt
  integer*2 jwave,icwid,id2
  integer soundout,ptt,nt(9)
  integer ib(14)
  real*8 tsec1,tsec2,trseconds
  include 'acom1.f90'
  include 'acom2.f90'
  common/bcom/ntransmitted
  common/dcom/jwave(NMAX2),icwid(NMAX3),id2(NMAX2)
  data ntx/0/,ns0/0/
  data message0/'dummy'/,ntxdf0/-999/,ntune0/-999/,snr0/-999.0/
  data iqmode0/-999/,iqtx0/-999/,nrpt/10/
  data ib/500,160,80,60,40,30,20,17,15,12,10,6,4,2/
  save ntx,ns0,message0,ntxdf0,ntune0,snr0,iqmode0,iqtx0,ib

  trseconds=60.d0*ntrminutes
  nfhopok=0                                ! Transmitting, don't hop 
  ierr=0
  call1=callsign
  call cs_lock('tx')

  call gmtime2(nt,tsec1)
  sectr=mod(tsec1,trseconds)
  write(19,1031) cdate(3:8),utctime(1:4),sectr,'PTT on  '
1031 format(a6,1x,a4,f7.2,2x,a8)
  call flush(19)

  if(pttmode.eq.'CAT') then
     if (nrig.eq.2509) then
        write(crig,'(i6)') nrig
        write(cbaud,'(i6)') nbaud
        write(cdata,'(i1)') ndatabits
        write(cstop,'(i1)') nstopbits
        cmnd='rigctl '//'-m'//crig//' -r USB T 1'
     else if(nrig.eq.1901) then
        cmnd='rigctl -m 1901 -r localhost T 1'
     else
        write(crig,'(i6)') nrig
        write(cbaud,'(i6)') nbaud
        write(cdata,'(i1)') ndatabits
        write(cstop,'(i1)') nstopbits
        do i=40,1,-1
           if(chs(i:i).ne.' ') go to 1
        enddo
1       iz=i
        cmnd='rigctl '//'-m'//crig//' -r '//catport//' -s'//cbaud//           &
             ' -C data_bits='//cdata//' -C stop_bits='//cstop//              &
             ' -C serial_handshake='//chs(:iz)//' T 1'
! Example rigctl command:
! rigctl -m 1608 -r /dev/ttyUSB0 -s 57600 -C data_bits=8 -C stop_bits=1 \
!   -C serial_handshake=Hardware T 1
     endif

     do irpt=1,nrpt
        iret=system(cmnd)
        if(iret.eq.0) go to 2
        print*,'Error executing rigctl to set Tx mode:',irpt,iret
        print*,cmnd
        call msleep(100)
     enddo
2    continue

  else
     if(nport.gt.0 .or. pttport(1:4).eq.'/dev') ierr=ptt(nport,pttport,1,iptt)
  endif

  write(cdbm,'(i3)'),ndbm
  call cs_unlock

  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  ntx=1-ntx
  i1=index(call1,' ')
  i2=index(call1,'/')

  if(i2.gt.0 .or. igrid6.ne.0) then
! WSPR_2 message, in two parts
     if(i2.le.0) then
        msg1=call1(1:i1)//grid//' '//cdbm
     else
        msg1=call1(:i1)//cdbm
     endif
     msg0='<'//call1(:i1-1)//'> '//grid6//' '//cdbm
     if(ntx.eq.1) message=msg1
     if(ntx.eq.0) message=msg0

  else
! Normal WSPR message
     message=call1(1:i1)//grid//' '//cdbm
  endif

  ntxdf=nint(1.e6*(ftx-f0)) - 1500
  if(iqmode.ne.0) then
     ntxdf=ntxdf + nfiq
  endif
  ctxmsg=message
  snr=99.0
  snrfile=appdir(:nappdir)//'/test.snr'

  call cs_lock('tx')
  open(18,file=snrfile,status='old',err=10)
  read(18,*,err=10,end=10) snr
10 close(18)
  call gmtime2(nt,tsec1)
  if(ntune.eq.0 .and. ntune2.ne.0) ntune2=0      !### ??? ###
  call cs_unlock

  newgen=0
  if(message.ne.message0 .or. ntxdf.ne.ntxdf0 .or.                    &
       ntune.ne.ntune0 .or. snr.ne.snr0 .or. iqmode.ne.iqmode0 .or.   &
       iqtx.ne.iqtx0) then
     message0=message
     ntxdf0=ntxdf
     ntune0=ntune
     snr0=snr
     iqmode0=iqmode
     iqtx0=iqtx
     call genwspr(message,ntxdf,ntune,snr,iqmode,iqtx,ntrminutes,   &
       appdir,nappdir,sending,jwave)
     newgen=1
  endif
  if(ntune.eq.0) then
     call cs_lock('tx')
     alltxt=appdir(:nappdir)//'/ALL_WSPR.TXT'
     open(13,file=alltxt,status='unknown',position='append')
     write(13,1010) linetx,ib(iband),message
 1010 format(a40,i4,' m: ',a22)
     close(13)
     call cs_unlock
  endif

  npts=112*48000
  if(ntrminutes.eq.15) npts=886*48000
  if(nsec.lt.ns0) ns0=nsec

  if(idint.ne.0 .and. (nsec-ns0)/60.ge.idint .and. iqmode.eq.0) then
! Generate and insert the CW ID.
! NB: CW ID is not yet implemented in I/Q mode, or in WSPR-15
     wpm=25.
     freqcw=1500.0 + ntxdf
     cwmsg=call1(:i1)//'                      '
     icwid=0
     call gencwid(cwmsg,wpm,freqcw,icwid,ncwid)
     k0=112*48000
     k1=k0+12000
     k2=k1+4.5*48000
     jwave(k0:k1)=0
     jwave(k1+1:k2)=icwid
     jwave(k2:)=0
     npts=k2
     ns0=nsec
  endif

  fac=10.0**(0.05*ntxdb)
  if(ntune.eq.0) then

! Normal WSPR transmission
     if(newgen.eq.1) then
        do i=1,npts*(iqmode+1)
           id2(i)=fac*jwave(i)
        enddo
        if(iqmode.eq.1) then
           call phasetx(id2,npts,txbal,txpha)
        endif
     endif

     call msleep(200)                     !T/R sequencing delay
     call gmtime2(nt,tsec2)

     call cs_lock('tx')
     sectr=mod(tsec2,trseconds)
     write(19,1031) cdate(3:8),utctime(1:4),sectr,'Tx Audio'
     call flush(19)
     call cs_unlock('tx')

!     tdiff=tsec2-tsec0
!     if(tdiff.lt.0.9) then
!        call msleep(100)
!        go to 20
!     endif
     istart=48000*(tsec2-tsec0)
     npts=npts-istart
     istart=istart*(iqmode+1)+1           !istart must be odd if iqmode=1
     if(istart.lt.1) istart=1
     ierr=soundout(ndevout,48000,id2(istart),npts,iqmode)

  else

     istart=2*48000 +1
     if(pctx.lt.100.0) then
! This is a "Tune" transmission
        npts=48000*pctx
        if(ntune.lt.0) npts=48000*abs(ntune)
        j=istart-1
        do i=1,npts*(iqmode+1)
           j=j+1
           id2(i)=fac*jwave(j)
        enddo
        if(iqmode.eq.1) then
           call phasetx(id2,npts,txbal,txpha)
        endif
        ierr=soundout(ndevout,48000,id2,npts,iqmode)

     else
! Send a series of dashes, for making I/Q phase adjustments.
        npts=24*4096
        do irpt=1,100
           fac=10.0**(0.05*ntxdb)
           j=istart-1
           do i=1,npts*(iqmode+1)
              j=j+1
              id2(i)=fac*jwave(j)
           enddo
           if(iqmode.eq.1) then
              call phasetx(id2,npts,txbal,txpha)
           endif
           ierr=soundout(ndevout,48000,id2,npts,iqmode)
        enddo
     endif
  endif
  if(ierr.ne.0) then
     print*,'Error in soundout',ierr
     stop
  endif

  call gmtime2(nt,tsec1)
  sectr=mod(tsec1,trseconds)
  write(19,1031) cdate(3:8),utctime(1:4),sectr,'Audio 0 '
  call flush(19)
  call cs_unlock('tx')

  call msleep(200)                        !T/R sequencing delay

  call cs_lock('tx')
  call gmtime2(nt,tsec1)
  sectr=mod(tsec1,trseconds)
  write(19,1031) cdate(3:8),utctime(1:4),sectr,'PTT Off '
  call flush(19)
  call cs_unlock('tx')

  if(pttmode.eq.'CAT') then
     if(nrig.eq.2509) then
        cmnd='rigctl '//'-m'//crig//' -r USB T 0'
     else if(nrig.eq.1901) then
        cmnd='rigctl -m 1901 -r localhost T 0'
     else
        cmnd='rigctl '//'-m'//crig//' -r'//catport//' -s'//cbaud//           &
             ' -C data_bits='//cdata//' -C stop_bits='//cstop//              &
             ' -C serial_handshake='//chs(:iz)//' T 0'
     endif

     call cs_lock('tx')
     do irpt=1,nrpt
        iret=system(cmnd)
        if(iret.eq.0) go to 101
        print*,'Error executing rigctl to set Rx mode:',irpt,iret
        print*,cmnd
        call msleep(100)
     enddo
101  continue
     call cs_unlock

  else
     if(nport.gt.0 .or. pttport(1:4).eq.'/dev') ierr=ptt(nport,pttport,0,iptt)
  endif

  ntxdone=1                        !Tx done
  if(ntune.ge.0) nfhopok=1         !Unless this was ATU tuneup, can now hop
  if(ntune.eq.0) ntransmitted=1    !Flag only "real" transmissions
  ntune=0                          !Clear the "tune" indicator

  return
end subroutine tx
