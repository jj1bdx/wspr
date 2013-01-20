program wspr_rxtest

  character arg*8
  include 'acom1.f90'

  nargs=iargc()
  if(nargs.ne.1 .and. nargs.ne.5) then
     print*,'Usage: wspr_rxtest infile [...]'
     print*,'       wspr_rxtest selftest txdf fdot snr iters'
     go to 999
  endif

  call getarg(1,arg)
  if(arg.eq.'selftest') then
     call getarg(2,arg)
     read(arg,*) ntxdf
     call getarg(3,arg)
     read(arg,*) fdot
     call getarg(4,arg)
     read(arg,*) snrdb
     call getarg(5,arg)
     read(arg,*) iters
     do iter=1,iters
!###        call genmept('K1JT        ','FN20',30,ntxdf,snrdb,iwave)
        call decode
     enddo
     go to 999

  else
     ltest=.true.
     do ifile=1,nargs
        call getarg(ifile,infile)
        len=80
        call getfile(infile,80)
        call decode
     enddo
  endif

999 end program wspr_rxtest

subroutine msleep(n)
  return
end subroutine msleep
