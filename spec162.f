      subroutine spec162(c2,jz,appdir,nappdir)

      parameter(NX=500,NY=160)
      complex c2(65536)
      complex c(0:255)
      character*80 appdir,pixmap
      real s(120,0:255)
      real ss(0:255)
      real w(0:255)
      real savg(0:255)
      integer*2 a(NX,NY)
      common/bcom/ntransmitted

      nfft=256
      twopi=6.2831853
      pi=0.5*twopi
      do i=0,nfft-1
         w(i)=sin(i*pi/nfft)
      enddo

      nadd=9
      call zero(s,120*256)
      call zero(savg,256)
      istep=nfft/2
      nsteps=(jz-nfft)/(nadd*istep)
      pixmap=appdir(:nappdir)//'/pixmap.dat'

      call cs_lock('spec162')
      open(16,file=pixmap,access='stream',status='unknown',err=1)
      read(16,end=1) a
      go to 2
 1    call zero(a,NX*NY/2)

 2    nmove=nsteps+1
      call cs_unlock

      do j=1,NY                 !Move waterfall left
         do i=1,NX-nmove
            a(i,j)=a(i+nmove,j)
         enddo
         a(NX-nmove+1,j)=255*ntransmitted
      enddo
      ntransmitted=0

      i0=-istep+1
      k=0
      do n=1,nsteps
         k=k+1
         call zero(ss,256)
         do m=1,nadd
            i0=i0+istep
            do i=0,nfft-1
               c(i)=w(i)*c2(i0+i)
            enddo
            call four2a(c,nfft,1,-1,1)
            do i=0,nfft-1
               sq=real(c(i))**2 + imag(c(i))**2
               ss(i)=ss(i) + sq
               savg(i)=savg(i) + sq
            enddo
         enddo
         call flat3(ss,256,nadd)
         do i=0,nfft-1
            s(k,i)=ss(i)
         enddo
      enddo
      kz=k

      gain=40
      offset=-90.
      fac=20.0/nadd

      do k=1,kz
         j=k-kz+NX
         do i=-80,-1
            x=fac*s(k,i+nfft)
            n=0
            if(x.gt.0.0) n=gain*log10(x) + offset
            n=min(252,max(0,n))
            a(j,NY-i-80)=n
         enddo
         do i=0,79
            x=fac*s(k,i)
            n=0
            if(x.gt.0.0) n=gain*log10(x) + offset
            n=min(252,max(0,n))
            a(j,NY-i-80)=n
         enddo
      enddo

      call cs_lock('spec162')
      rewind 16
      write(16) a
      close(16)
      call cs_unlock

      return
      end
