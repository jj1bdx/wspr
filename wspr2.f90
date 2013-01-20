subroutine wspr2

! Logical units:
!  12  Audio data in *.wav file
!  13  ALL_WSPR.TXT
!  14  decoded.txt
!  16  pixmap.dat
!  17  audio_caps
!  18  test.snr
!  19  wspr.log

  character message*24,cdbm*4
  real*8 tsec,tsec1,trseconds
  include 'acom1.f90'
  include 'acom2.f90'
  character dectxt*80,logfile*80
  integer nt(9)
  integer iclock(12)
  integer ib(15)
  common/patience/npatience
  data receiving/.false./,transmitting/.false./
  data nrxnormal/0/,ireset/1/
  data ib/630,160,80,60,40,30,20,17,15,12,10,6,4,2,630/
  save ireset

  ntrminutes=2
  call cs_init
  dectxt=appdir(:nappdir)//'/decoded.txt'

  call cs_lock('wspr2')
  open(14,file=dectxt,status='unknown')
  write(14,1002)
1002 format('$EOF')
  call flush(14)
  rewind 14
  logfile=appdir(:nappdir)//'/wspr.log'
  open(19,file=logfile,status='unknown',position='append')
  call cs_unlock

  npatience=1
  call system_clock(iclock(1))
  call random_seed(PUT=iclock)
  nrx=1
  nfhopping=0 ! hopping scheduling disabled
  nfhopok=0   ! not a good time to hop

10 call cs_lock('wspr2')
  trseconds=60.d0*ntrminutes
  call getutc(cdate,utctime,tsec)
  nsec=tsec
  nsectr=mod(nsec,60*ntrminutes)
  rxavg=1.0
  if(pctx.gt.0.0) rxavg=100.0/pctx - 1.0
  call cs_unlock
!  if(transmitting .and. nstoptx.eq.1) then
!     call killtx
!     nstoptx=0
!     transmitting=.false.
!     go to 20
!  endif

  if(nrxdone.gt.0) then

     call cs_lock('wspr2')
     receiving=.false.
     nrxdone=0
     thisfile=cdate(3:8)//'_'//rxtime(1:4)//'.'//'wav'    !Tnx to G3WKW !
     if(ndiskdat.ne.0) thisfile=outfile
     call cs_unlock

     if((nrxnormal.eq.1 .and. ncal.eq.0) .or.                          &
        (nrxnormal.eq.0 .and. ncal.eq.2) .or. ndiskdat.eq.1) then
        call cs_lock('wspr2')
        call gmtime2(nt,tsec1)
        sectr=mod(tsec1,trseconds)
        write(19,1031) cdate(3:8),utctime(1:4),sectr,'Dec ',iband,ib(iband)
1031    format(a6,1x,a4,f7.2,2x,a4,2i4,2x,a22)
        call flush(19)
        call cs_unlock
        if(ndecoding.eq.0) then
           ndecoding=1
           call startdec
        else
           print*,'Attempted to start decode thread when already running.'
        endif
     endif
  endif

  call cs_lock('wspr2')
  if(ntxdone.gt.0) then
     transmitting=.false.
     ntxdone=0
     ntr=0
  endif
  nsecdone=60*ntrminutes - 6                       !### Less for WSPR-15 ?
  if(nsectr.ge.nsecdone .and. ntune.eq.0) then
     transmitting=.false.
     receiving=.false.
     ntr=0
  endif
  if(pctx.lt.1.0) ntune=0
  call cs_unlock

  if (ntune.ne.0 .and. ndevsok.eq.1.and. (.not.transmitting) .and.   &
       (.not.receiving) .and. pctx.ge.1.0) then

! Test transmission of length pctx seconds.
     call cs_lock('wspr2')
     nsectx=mod(nsec,86400)
     ntune2=ntune
     transmitting=.true.
     call gmtime2(nt,tsec1)
     sectr=mod(tsec1,trseconds)
     if(ntune.eq.-3 .and. sectr.lt.116.5) then
        write(19,1031) cdate(3:8),utctime(1:4),sectr,'ATU ',iband,ib(iband)
     else
        write(19,1031) cdate(3:8),utctime(1:4),sectr,'Tune',iband,ib(iband)
     endif
     call flush(19)
     call cs_unlock
     call starttx
  endif

  if (ncal.eq.1 .and. ndevsok.eq.1.and. (.not.transmitting) .and.   &
       (.not.receiving)) then

! Execute one receive sequence
     call cs_lock('wspr2')
     receiving=.true.
     rxtime=utctime(1:4)
     nrxnormal=0
     call gmtime2(nt,tsec1)
     sectr=mod(tsec1,trseconds)
     write(19,1031) cdate(3:8),utctime(1:4),sectr,'Cal ',iband,ib(iband)
     call flush(19)
     call cs_unlock
     ndiskdat=0
     call startrx
  endif

  if(nsectr.eq.0 .and. (.not.transmitting) .and. (.not.receiving) .and. &
       (idle.eq.0)) go to 30
  if(receiving) then
     call chklevel(kwave,ntrminutes,iqmode+1,NZ/2,nsec1,xdb1,xdb2,iwrite)
     if(iqmode.eq.1 .and. iqrxadj.eq.1) then
        call speciq(kwave,NZ/2,iwrite,iqrx,nfiq,ireset,gain,phase,reject)
     else
        ireset=1
     endif
  endif

20 call msleep(200)
  go to 10

30 outfile=cdate(3:8)//'_'//utctime(1:4)//'.'//'wav'

! Frequency hopping scheduling; overrides normal scheduling
  if (nfhopping.eq.1) then
     if (pctx.eq.0.0) then
        nrx=1
     else
        if(ncoord.eq.0) then
           call random_number(x)
           if (100*x .lt. pctx) then
              ntxnext=1
           else
              nrx=1
           endif
        else
           call rxtxcoord(nsec,pctx,nrx,ntxnext)
        endif
     endif
  else
     if(pctx.eq.0.0) nrx=1
  endif

  if(transmitting .or. receiving) go to 10

  if(pctx.gt.0.0 .and. (ntxnext.eq.1 .or. (nrx.eq.0 .and. ntr.ne.-1))) then

     call cs_lock('wspr2')
     ntune2=ntune
     transmitting=.true.
     call random_number(x)
     if(pctx.lt.50.0) then
        nrx=nint(rxavg + 3.0*(x-0.5))
     else
        nrx=0
        if(x.lt.rxavg) nrx=1
     endif
     write(cdbm,'(i4)') ndbm
     message=callsign//grid//cdbm
     call msgtrim(message,msglen)
     write(linetx,1030) cdate(3:8),utctime(1:4),ftx
1030 format(a6,1x,a4,f11.6,2x,'Transmitting on ')
     ntr=-1
     nsectx=mod(nsec,86400)
     ntxdone=0
     ntxnext=0
     call cs_unlock

     if(ndevsok.eq.1) then
        call cs_lock('wspr2')
        call gmtime2(nt,tsec0)
        sectr=mod(tsec0,trseconds)
        write(19,1031) cdate(3:8),utctime(1:4),sectr,'Tx  ',iband,ib(iband),  &
             message
        call flush(19)
        call cs_unlock
        call starttx
     endif

  else
     receiving=.true.
     rxtime=utctime(1:4)
     ntr=1
     if(ndevsok.eq.1) then
        nrxnormal=1
        call cs_lock('wspr2')
        call gmtime2(nt,tsec1)
        sectr=mod(tsec1,trseconds)
        write(19,1031) cdate(3:8),utctime(1:4),sectr,'Rx  ',iband,ib(iband)
        call flush(19)
        call cs_unlock
        call startrx
     endif
     nrx=nrx-1
  endif
  go to 10

  return
end subroutine wspr2
