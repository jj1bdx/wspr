subroutine write_wav(lu,idat,ntot,nfsample,nchan)

! Write a wavefile to logical unit lu.

  integer*2 idat(ntot)
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
  integer*1 hdr(44)
  common/hdr/ariff,nchunk,awave,afmt,lenfmt,nfmt2,nchan2,nsamrate,   &
       nbytesec,nbytesam2,nbitsam2,adata,ndata
  equivalence (hdr,ariff)

! Generate header
  ariff='RIFF'
  awave='WAVE'
  afmt='fmt '
  adata='data'
  lenfmt=16                             !Rest of this sub-chunk is 16 bytes long
  nfmt2=1                               !PCM = 1
  nchan2=nchan                          !1=mono, 2=stereo
  nbitsam2=16                           !Bits per sample
  nsamrate=nfsample                     !Sample rate
  nbytesec=nfsample*nchan2*nbitsam2/8   !Bytes per second
  nbytesam2=nchan2*nbitsam2/8           !Block-align               
  ndata=ntot*nbitsam2/8
  nbytes=ndata+44
  nchunk=nbytes-8

  write(lu) hdr
  write(lu) idat

  return
end subroutine write_wav
