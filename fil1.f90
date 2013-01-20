subroutine fil1(id1,n1,id2,n2)

! FIR lowpass filter designed using ScopeFIR

! fsample     = 48000 Hz
! Ntaps       = 37
! fc          = 3000  Hz
! fstop       = 6000  Hz
! Ripple      = 1     dB
! Stop Atten  = 60    dB
! fout        = 12000 Hz

  parameter (NTAPS=37)
  parameter (NH=NTAPS/2)
  parameter (NDOWN=4)             !Downsample ratio
  integer*2 id1(n1)
  integer*2 id2(*)

! Filter coefficients:
  real a(-NH:NH)
  data a/                                                                 &
        0.001377395235, 0.002852158900, 0.004767882543, 0.006240206517,   &
        0.006191755970, 0.003553573051,-0.002243564850,-0.010770446408,   &
       -0.020288158399,-0.027822309390,-0.029710933359,-0.022547471263,   &
       -0.004298056801, 0.024769757851, 0.061669077060, 0.101014185634,   &
        0.136070596894, 0.160295785231, 0.168947734090, 0.160295785231,   &
        0.136070596894, 0.101014185634, 0.061669077060, 0.024769757851,   &
       -0.004298056801,-0.022547471263,-0.029710933359,-0.027822309390,   &
       -0.020288158399,-0.010770446408,-0.002243564850, 0.003553573051,   &
        0.006191755970, 0.006240206517, 0.004767882543, 0.002852158900,   &
        0.001377395235/

  n2=(n1-NTAPS+NDOWN)/NDOWN
  k0=NH-NDOWN+1

! Loop over all output samples
  do i=1,n2
     s=0.
     k=k0 + NDOWN*i
     do j=-NH,NH
        s=s + id1(j+k)*a(j)
     enddo
     id2(i)=nint(s)
  enddo

  return
end subroutine fil1
