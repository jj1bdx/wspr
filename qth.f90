program qth

  parameter (NMAX=100)
  real xlon1(NMAX),xlon2(NMAX)
  real xlat1(NMAX),xlat2(NMAX)
  real ddelay(NMAX)
  real sigma(NMAX)
  real chisq(-10:10,-10:10)
  character*6 call1(NMAX),call2(NMAX)
  character*6 grid1(NMAX),grid2(NMAX)
  character infile*40
  character*12 arg

  nargs=iargc()
  if(nargs.ne.2) then
     print*,'Usage: qth <infile> <iters>'
     go to 999
  endif
  call getarg(1,infile)
  call getarg(2,arg)
  read(arg,*) iters

  open(10,file=infile,status='old')
  open(12,file='qth.out',status='unknown')

  do i=1,NMAX
     read(10,1010,end=10) call1(i),grid1(i),call2(i),grid2(i),ddelay(i),sigma(i)
1010 format(a6,1x,a6,2x,a6,1x,a6,2f7.2)
     if(sigma(i).eq.0.0) sigma(i)=0.08
     call grid2deg(grid1(i),xlon1(i),xlat1(i))
     call grid2deg(grid2(i),xlon2(i),xlat2(i))
     xlon1(i)=-xlon1(i)
     xlon2(i)=-xlon2(i)
  enddo
  i=NMAX+1

10 iz=i-1

  xlon0=-80
  xlat0=40
!  xlon0=40
!  xlat0=55
  dlon=4.0
  dlat=4.0
  i0=10

  sqmin=1.e30
  do iter=1,iters
     do ilon=-i0,i0
        xlon=xlon0 + ilon*dlon
        do ilat=-i0,i0
           xlat=xlat0 + ilat*dlat
           sq=0.
           do i=1,iz
              call geodist(xlat,-xlon,xlat1(i),-xlon1(i),az1,baz1,dist1)
              call geodist(xlat,-xlon,xlat2(i),-xlon2(i),az2,baz2,dist2)
              calc_ddelay=(dist1-dist2)/300.0
              resid=ddelay(i)-calc_ddelay
              sq=sq + (resid/sigma(i))**2
           enddo
           chisq(ilon,ilat)=sq/(iz-2)
           if(sq.lt.sqmin) then
              blon=xlon
              blat=xlat
              sqmin=sq
           endif
        enddo
     enddo
     
!      call geodist(39.0653,-84.6075,blat,blon,az,baz,dist)
!     call geodist(55.75,37.28,blat,blon,az,baz,dist)
    call geodist(41.7292,-72.7083,blat,blon,az,baz,dist)
     write(*,1030) iter,blon,blat,sqmin,dist
1030 format(i3,2f10.4,f10.2,3f8.0)
     if(iter.eq.iters) then
        call geodist(blat,blon,blat,blon+dlon,az,baz,dx)
        call geodist(blat,blon,blat+dlat,blon,az,baz,dy)
        write(*,1030)
        write(*,1032) blon,blat,dx,dy
        write(12,1032) blon,blat,dx,dy
1032    format('Lon:',f7.2,'   Lat:',f7.2,'   dx_km:',f6.1,'   dy_km:',f6.1)
        write(*,1040) (i*dlon,i=-5,5)
1040    format(7x,13f6.2)
        write(12,1042) (i*dlon,i=-5,5)
1042    format(7x,13f6.2)
        do j=6,-6,-1
           write(*,1050)  j*dlat,(nint(chisq(i,j)),i=-5,5)
1050       format(f5.2,2x,13i6)
           write(12,1060) j*dlat,(nint(chisq(i,j)),i=-5,5)
1060       format(f5.2,2x,13i6)
        enddo
     endif
     xlon0=blon
     xlat0=blat
     dlon=0.5*dlon
     dlat=0.5*dlat
     sqmin=1.e30
  enddo

999 end program qth
