subroutine wspr0init(ntrminutes,nrxtx,nport,nfiles,multi,list,snrdb,   &
     pctx,f0,ftx,call12,grid6,ndbm,outfile)

  real*8 f0,ftx,txaudio
  character*12 arg
  character*12 call12
  character*6 grid6
  character*80 outfile

  nargs=iargc()
  if(nargs.eq.0) then
     print*,' '
     print*,'wspr0 -- version 4.0'
     print*,' '
     print*,'Usage: wspr0 [options...] [files...]'
     print*,' '
     print*,'Options:'
     print*,' '
     print*,'Transmit/Receive status:'
     print*,'       -t   Run in 100% Tx mode. (Default is Rx mode.)'
     print*,'       -b   Pseudo-random selection of Rx and Tx cycles.'
     print*,'       -D   Open and decode one or more wav files.'
     print*,' '
     print*,'Transmitted message: by default, the callsign, grid locator,'
     print*,'and power level for the transmitted message are taken from'
     print*,'file wspr0.def. These may be overridden by using the options'
     print*,'       -c call'
     print*,'       -g grid'
     print*,'       -d dBm'
     print*,' '
     print*,'Frequencies:'
     print*,'       -f x   Transceiver dial frequency is x (MHz)'
     print*,'       -F x   Center frequency of transmission is x (MHz)'
     print*,'       -a x   Audio frequency of transmission is x (Hz)'
     print*,' '
     print*,'       -m     Run in WSPR-15 mode (default is WSPR-2)'
     print*,'       -n n   Number of files to be generated'
     print*,'       -o outfile   Output filename, overrides default nnnnnn.'
     print*,'       -p n   PTT port'
     print*,'       -P n   Transmitting percent (default=25)'
     print*,'       -s x   SNR of generated data, dB (default 100)'
     print*,'       -x     Generate test file(s) with 10 signals in each'
     print*,'       -X     Generate list of audio tones for this message'
     print*,' '
     print*,'Examples:'
     print*,'       wspr0 -t                      #Transmit default message'
     print*,'       wspr0 -t -s -22 -o test.wav   #Generate a test file'
     print*,'       wspr0 -t -s -25 -n 3          #Generate three test files'
     print*,'       wspr0 -b                      #Randomized T/R sequences'
     print*,'       wspr0 -f 14.0956              #Rx only, on 20m'
     print*,'       wspr0 -D 00001.wav 00002.wav  #Decode these two files'
     print*,' '
     print*,'For more information see:'
     print*,'       physics.princeton.edu/pulsar/K1JT/WSPR0_Instructions.TXT'
     stop
  endif

  nrxtx=1
  ntrminutes=2
  nfiles=9999
  nport=2
  snrdb=100.
  call12='K1JT'
  grid6='FN20qi'
  ndbm=37
  pctx=25.
  outfile=" "
  f0=10.138700d0
  ftx=10.140200d0
  txaudio=0.d0
  mfiles=0
  k=0
  multi=0
  list=0

  do n=1,99
     k=k+1
     call getarg(k,arg)
     if(arg(1:2).eq.'-m') then
        ntrminutes=15
     else if(arg(1:2).eq.'-D') then
        nrxtx=1
     else if(arg(1:2).eq.'-t') then
        nrxtx=2
     else if(arg(1:2).eq.'-b') then
        nrxtx=3
     else if(arg(1:2).eq.'-c') then
        k=k+1
        call getarg(k,call12)
     else if(arg(1:2).eq.'-g') then
        k=k+1
        call getarg(k,grid6)
     else if(arg(1:2).eq.'-d') then
        k=k+1
        call getarg(k,arg)
        read(arg,*) ndbm
     else if(arg(1:2).eq.'-f') then
        k=k+1
        call getarg(k,arg)
        read(arg,*) f0
     else if(arg(1:2).eq.'-F') then
        k=k+1
        call getarg(k,arg)
        read(arg,*) ftx
     else if(arg(1:2).eq.'-a') then
        k=k+1
        call getarg(k,arg)
        read(arg,*) txaudio
     else if(arg(1:2).eq.'-n') then
        k=k+1
        call getarg(k,arg)
        read(arg,*) nfiles
     else if(arg(1:2).eq.'-s') then
        k=k+1
        call getarg(k,arg)
        read(arg,*) snrdb
     else if(arg(1:2).eq.'-p') then
        k=k+1
        call getarg(k,arg)
        read(arg,*) nport
     else if(arg(1:2).eq.'-P') then
        k=k+1
        call getarg(k,arg)
        read(arg,*) pctx
        pctx=min(max(pctx,0.0),100.0)
     else if(arg(1:2).eq.'-o') then
        k=k+1
        call getarg(k,outfile)
     else if(arg(1:2).eq.'-x') then
        multi=1
        snrdb=0.
     else if(arg(1:2).eq.'-X') then
        list=1
     else
        mfiles=mfiles+1
     endif
     if(k.ge.nargs) exit
  enddo

  if(outfile(1:1).ne.' ') nfiles=1
  if(nrxtx.eq.1) nfiles=mfiles
  if(txaudio.ne.0.d0) ftx=f0 + 1.d-6*txaudio
  
  return
end subroutine wspr0init

