program wspr0

! Command-line version of WSPR.

  integer nt(9)
  integer soundexit
  real*8 f0,ftx,tsec
  character*12 call12
  character*6 grid6
  character*80 outfile
  character*11 utcdate
  character*3 month(12)
  data month/'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'/

  call wspr0init(ntrminutes,nrxtx,nport,nfiles,multi,list,snrdb,       &
       pctx,f0,ftx,call12,grid6,ndbm,outfile)

  ntr=0
  nsec0=999999
  open(14,file='ALL_WSPR0.TXT',status='unknown',access='append')
  call soundinit

  if(nrxtx.eq.1) then                            !Receive only
        write(*,1026)
1026    format(' UTC  dB   DT    Freq       Message'/54('-'))
        write(14,1028)
1028    format(' Date   UTC Sync dB   DT    Freq       Message'/50('-'))
     call wspr0_rx(ntrminutes,nrxtx,nfiles,f0)

  else if(nrxtx.eq.2) then                       !Transmit only
     call wspr0_tx(ntrminutes,nport,nfiles,multi,list,snrdb,f0,ftx,    &
          call12,grid6,ndbm,outfile,ntr)
  else if(nrxtx.eq.3) then                       !Tx and Rx, choosen randomly
     call random_seed
     ntr=1
20   nsec=time()
     call gmtime2(nt,tsec)
     nsec=tsec
     write(utcdate,1001) nt(4),month(nt(5)),nt(6)
1001 format(i2,'-',a3,'-',i4)
     nsec=mod(nsec,86400)
     if(nsec.lt.nsec0) then
        write(*,1026)
        write(14,1028)
     endif
     nsec0=nsec

     call random_number(x)
     if(100.0*x.lt.pctx) then
        call wspr0_tx(ntrminutes,nport,nfiles,multi,list,snrdb,f0,ftx,   &
             call12,grid6,ndbm,outfile,ntr)
     else
        call wspr0_rx(ntrminutes,f0,ntr)
     endif
     call msleep(100)
     go to 20
  endif

  ierr=soundexit()

end program wspr0
