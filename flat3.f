      subroutine flat3(ss0,n,nsum)

      parameter (NZ=256)
      real ss0(NZ)
      real ss(NZ)
      real ref(NZ)
      real tmp(NZ)

      call move(ss0,ss(129),128)
      call move(ss0(129),ss,128)

      nsmo=20
      base=50*(float(nsum)**1.5)
      ia=nsmo+1
      ib=n-nsmo-1
      do i=ia,ib
         call pctile(ss(i-nsmo),tmp,2*nsmo+1,35,ref(i))
      enddo
      do i=ia,ib
         ss(i)=base*ss(i)/ref(i)
      enddo

      call move(ss(129),ss0,128)
      call move(ss,ss0(129),128)

      return
      end
