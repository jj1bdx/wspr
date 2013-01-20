subroutine read_wav(lu,idat,npts,nfsample,nchan)

! Write a wavefile to logical unit lu.

  integer*2 idat(*)
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
  integer*1 hdr(44)
  common/hdr/ariff,nchunk,awave,afmt,lenfmt,nfmt2,nchan2,nsamrate,   &
       nbytesec,nbytesam2,nbitsam2,adata,ndata
  equivalence (hdr,ariff)

  read(lu) hdr
  npts=ndata/(nchan2*nbitsam2/8)
  nfsample=nsamrate
  nchan=nchan2
  read(lu) (idat(i),i=1,npts*nchan)

  return
end subroutine read_wav
