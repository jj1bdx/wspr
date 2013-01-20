      subroutine sync162(c2,jz,ps,sstf,kz)

C  Find MEPT_JT sync signals, with best-fit DT and DF.  

      complex c2(jz)
      parameter (NFFT=512)             !Length of FFTs
      parameter (NH=NFFT/2)            !Length of power spectra
      parameter (NSMAX=351)            !Number of half-symbol steps
      parameter (NF0=136,NF1=10)
      parameter (LAGMAX=26)
      real psavg(-NH:NH)               !Average spectrum of whole record
      real s2(-NH:NH,NSMAX)            !2d spectrum, stepped by half-symbols
      real ps(-NH:NH)
      real psmo(-NH:NH)
      real freq(-NH:NH)
      real p1(-NH:NH)
      real drift(-NH:NH)
      real dtx(-NH:NH)
      integer keep0(-NH:NH)
      integer keep(-NH:NH)
      real a(5)
      real sstf(5,275)
      real tmp(275)
      integer npr3(162)
      real pr3(162)
      data npr3/
     +  1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,
     +  0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,
     +  0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,
     +  1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,
     +  0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,
     +  0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,
     +  0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,
     +  0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,
     +  0,0/
      save

      nsym=162
      do i=1,nsym
         pr3(i)=2*npr3(i)-1
      enddo

C  Do FFTs of twice symbol length, stepped by half symbols.  
      nq=NFFT/4
      nsteps=jz/nq - 1
      df=375.0/nfft
      dt=1.0/375.0
      call zero(psavg,NFFT+1)

C  Compute power spectrum for each step, and get average
      do j=1,nsteps
         k=(j-1)*nq + 1
         call ps162(c2(k),s2(-NH,j))
         call add(psavg,s2(-NH,j),psavg,NFFT)
      enddo

! Normalize and subtract baseline from psavg.
      call pctile(psavg(-136),tmp,273,35,base)
      psavg=psavg/base - 1.0
      base=base/351.0
      s2=s2/base - 1.0

! Boxcar-smooth the average spectrum over the WSPR signal bandwidth.
      do i=-NH+3,NH-3
         psmo(i)=0.
         do k=-3,3
            psmo(i)=psmo(i)+ps(i+k)
         enddo
         psmo(i)=psmo(i)/7.0
      enddo

! Mark potential suspects for WSPR signals.  
! (Keep only the best one within a surrounding range of +/- 8 bins.)

      plimit=0.1                      !### Are the plimit values OK? ###
      do i=-NF0,NF0
         keep0(i)=0
         keep(i)=0
         ia=i-4
         ib=i+4
         pmax=-1.e30
         do ii=ia,ib
            if(psmo(ii).gt.pmax) then
               ipk=ii
               pmax=psmo(ii)
            endif
         enddo
         if(ipk.eq.i .and. pmax.ge.plimit) then
            keep0(i)=1
! Kill all smaller peaks leading up to this maximum.
            do ii=ia,i-1
               keep0(ii)=0
            enddo
         endif
      enddo

! Now mark the bins +/- 1 from each one already marked.
      do i=-NF0+1,NF0-1
         if(keep0(i).eq.1) then
            keep(i-1)=1
            keep(i)=1
            keep(i+1)=1
         endif
      enddo

! Now do the main search over DT, DF, and drift.  (Do CCFs in all marked
! frequency bins and over a range of reasonable fdot values and lags.)
      p1=0.
      do i=-NF0,NF0
         if(keep(i).eq.0) go to 10
         smax=0.
         do k=-NF1,NF1
            if(abs(k).ne.1) then
               do lag=0,LAGMAX
                  sum=0.
                  n=lag-1
                  do j=1,162
                     n=n+2
                     ii=i + nint(k*(j-81)/162.0)
                     x=max(s2(ii-1,n),s2(ii+3,n)) - 
     +                    max(s2(ii-3,n),s2(ii+1,n))
                     sum=sum + x*pr3(j)
                  enddo
                  if(sum.gt.smax) then
                     kpk=k
                     lagpk=lag
                     smax=sum
                  endif
               enddo
            endif
         enddo

! Save the CCF value, frequency, drift rate, and DT.
         p1(i)=smax
         freq(i)=df*i
         drift(i)=df*kpk
         dtx(i)=128.0*dt*lagpk
 10      continue
      enddo

! Eliminate potential duplicates and peaks smaller than plimit.
      keep=0
      plimit=1.0
      do i=-NF0,NF0
         ia=max(-NF0,i-8)
         ib=min(NF0,i+8)
         pmax=-1.e30
         do ii=ia,ib
            if(p1(ii).gt.pmax) then
               ipk=ii
               pmax=p1(ii)
            endif
         enddo
         if(ipk.eq.i .and. pmax.ge.plimit) then
            keep(i)=1
            do ii=ia,i-1
               keep(ii)=0
            enddo
         endif
      enddo

! Compress the candidate list, saving only the potentially important ones.
! Recalibrate sync indicator p1 on a dB scale.  
! (NB: p1 sould be compared with snrx!)
      k=0
      do i=-NF0,NF0
         if(keep(i).ne.0) then
            x=10.0*log10(p1(i)) - 22
            if(x.ge.0.5) then
               k=min(k+1,275)
               p1(k)=x
               freq(k)=freq(i)
               drift(k)=drift(i)
               dtx(k)=dtx(i) - 2.0
            endif
         endif
      enddo
      kz=k

      do k=1,kz
         a(1)=-freq(k)
         a(2)=-0.5*drift(k)
         a(3)=0.
         lagpk=nint((dtx(k)+2)/(128*dt))
         lag1=max(-200,8*lagpk-16)
         lag2=min(200,8*lagpk+16)
         ccf=fchisq(c2,jz,375.0,a,lag1,lag2,ccfbest,dtbest)
         ipk=nint(freq(k)/df)
         snrx=db(max(psavg(ipk),0.0001)) - 26.5         !Empirical
         sstf(1,k)=p1(k)
         sstf(2,k)=snrx
         sstf(3,k)=dtbest-2.0
         sstf(4,k)=freq(k)
         sstf(5,k)=drift(k)
      enddo
      
      return
      end

