subroutine ftn_quit

  call cs_lock('ftn_quit')
  rewind 17
  call export_wisdom_to_file(17)
  close(17)
  write(*,1000) 
1000 format('Exported FFTW wisdom')
  call four2a(a,-1,1,1,1)                  !Destroy the FFTW plans
  call cs_unlock
  call cs_destroy

  return
end subroutine ftn_quit
