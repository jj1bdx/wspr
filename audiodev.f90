subroutine audiodev(jdevin,jdevout,inbad,outbad)

!                        !f2py threadsafe
!f2py intent(in)  jdevin,jdevout
!f2py intent(out) inbad,outbad

  character cdevice*40,audiocaps*80
  integer inbad,outbad
  integer nchin(0:40),nchout(0:40),inerr(0:40),outerr(0:40)
  include 'acom1.f90'

  call padevsub(numdevs,ndefin,ndefout,nchin,nchout,inerr,outerr)

  audiocaps=appdir(:nappdir)//'/audio_caps'
  open(17,file=audiocaps,status='unknown')
  inbad=1
  do i=0,numdevs-1
     read(17,1101,end=10,err=10) cdevice
1101 format(29x,a40)
     i1=index(cdevice,':')
     if(i1.gt.10) cdevice=cdevice(:i1-1)
     if(nchin(i).gt.0 .and. inerr(i).eq.0) then
        if(i.eq.jdevin) inbad=0
     endif
  enddo

10  rewind 17
  outbad=1
  do i=0,numdevs-1
     read(17,1101,end=20,err=20) cdevice
     i1=index(cdevice,':')
     if(i1.gt.10) cdevice=cdevice(:i1-1)
     if(nchout(i).gt.0 .and. outerr(i).eq.0) then
        if(i.eq.jdevout) outbad=0
     endif
  enddo
20 close(17)

  return
end subroutine audiodev
