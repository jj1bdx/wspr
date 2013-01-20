program fmeasure

  parameter(NZ=1000)
  implicit real*8 (a-h,o-z)
  real*8 fd(NZ),deltaf(NZ),r(NZ)
  character infile*50
  character line*80

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage:   fmeasure <infile>'
     print*,'Example: fmeasure fmtave.out'
     go to 999
  endif
  call getarg(1,infile)

  open(10,file=infile,status='old',err=997)
  open(11,file='fcal.out',status='old',err=998)
  open(12,file='fmeasure.out',status='unknown')

  read(11,*) a,b

  write(*,1000) 
  write(12,1000) 
1000 format('    Freq     DF     A+B*f     Corrected'/        &
            '   (MHz)    (Hz)    (Hz)        (MHz)'/        &
            '----------------------------------------')       
  i=0
  do j=1,9999
     read(10,1010,end=999) line
1010 format(a80)
     i0=index(line,' 0 ')
     if(i0.gt.0) then
        read(line,*,err=5) f,df
        dial_error=a + b*f
        fcor=f + 1.d-6*df - 1.d-6*dial_error
        write(*,1020) f,df,dial_error,fcor
        write(12,1020) f,df,dial_error,fcor
1020    format(3f8.3,f15.9)     
     endif
5    continue
  enddo

  go to 999

997 print*,'Cannot open input file: ',infile
  go to 999
998 print*,'Cannot open fcal.out'

999 end program fmeasure
