      subroutine twkfreq(ca,cb,jz,a)

C  Apply AFC corrections to ca, returning corrected data in cb

      complex ca(jz),cb(jz)
      real a(5)
      real*8 twopi
      complex*16 w,wstep
      data twopi/0.d0/
      save twopi

      if(twopi.eq.0.d0) twopi=8.d0*atan(1.d0)
      w=1.d0
      wstep=1.d0
      x0=0.5*(jz+1)
      s=2.0/jz
      do i=1,jz
         x=s*(i-x0)
         if(mod(i,100).eq.1) then
            p2=1.5*x*x - 0.5
!            p3=2.5*(x**3) - 1.5*x
!            p4=4.375*(x**4) - 3.75*(x**2) + 0.375
            dphi=(a(1) + x*a(2) + p2*a(3)) * (twopi/375.0)
            wstep=cmplx(cos(dphi),sin(dphi))
         endif
         w=w*wstep
         cb(i)=w*ca(i)
      enddo

      return
      end
