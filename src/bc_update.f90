!--------------------------------------------------------------------
!
! Update and apply the boundary conditins in STRESSES 
!
!--------------------------------------------------------------------
subroutine bc_update  
  !----------------------- determ. boundary conditions -----------

  use arrays
  include 'precision.inc'
  include 'arrays.inc'
  include 'params.inc'
!--------------------- update leftside velocity 
!wt =-real(cord(1,1,2)/1000.0)
!if (nofside(i).eq.1)then
!  fun = bca(i)+0.5*2.0*wt*1.0e-9
!else
!do i = 1,nofbc
!if (nofside(i).eq.1) then
!  ii1 = 1
!  jj1 = numbp
!  fun = bca(i) +0.5 * 0.2 *wt *1.0e-9
!endif
!if (nofside(i).eq.3) then
!  ii1 = nx
!  jj1= numbp
!  fun = bca(i)
!end if
!if (nbc(i) .eq.10) then
!    ncod(jj1,ii1,1) = 1
!    if (abs(bc(jj1,ii1,1)).gt.0) then
!       fun = bc(jj1,ii1,1)
!    end if
!      bc(jj1,ii1,1) = fun
!end if 

!end do

! write(*,*)nofside(i),bc(jj1,ii1,1)

 

 ! -------------------------------------------------------------
  !      LEFT BOUNDARY
  !   Update for hydrostatic force (normal to the surface)
  !   Shear component = 0 (perfect fluid)
  ! -------------------------------------------------------------
  force = 0.0
  balance = 0.0

  if (ydrsides.eq. 1.) then
      rogh = 0.      
      do j=1,nz-1
          iph = iphase(j,1)
          densT = Eff_dens(j,1)
          dh1 = cord (j,1,2) - cord (j+1,1,2)
          dh2 = cord (j,2,2) - cord (j+1,2,2)
          dh  = 0.5 * (dh1+dh2)
          dPT = densT * g * dh
          dP = dPT * ( 1 - beta(iph)*rogh ) / ( 1 + beta(iph)/2*dPT )
          press = rogh +0.5*dP 

          dlx = cord(j+1,1,1)-cord(j,1,1)
          dly = cord(j+1,1,2)-cord(j,1,2)
          press_norm = -press
          ! Normal component
          !           projection on x
          force(j,1,1) = force(j,1,1)+0.5*press_norm*dly
          force(j+1,1,1) = force(j+1,1,1)+0.5*press_norm*dly
          !        write(*,*) j,force(j,1,1),force(j+1,1,1)

          !           projection on y
          force(j,1,2) = force(j,1,2)-0.5*press_norm*dlx
          force(j+1,1,2) = force(j+1,1,2)-0.5*press_norm*dlx

          balance(j,1,1) = 1.e+17
          balance(j+1,1,1) = 1.e+17
          rogh = rogh +dP 
      enddo


      ! -------------------------------------------------------------
      !      RIGHT BOUNDARY
      !   Update for hydrostatic force (normal to the surface)
      !   Shear component = 0 (perfect fluid)
      ! -------------------------------------------------------------
      rogh = 0.
      do j=1,nz-1
          iph = iphase(j,nx-1)
          densT = Eff_dens(j,nx-1)
          dh1 = cord (j,nx-1,2) - cord (j+1,nx-1,2)
          dh2 = cord (j,nx,2) - cord (j+1,nx,2)
          dh  = 0.5 * (dh1+dh2)
          dPT = densT * g * dh
          dP = dPT * ( 1 - beta(iph)*rogh ) / ( 1 + beta(iph)/2*dPT )
          press = rogh +0.5*dP

          !        write(*,*) j,stress0(j,nx-1,1,1),press_norm,densT
          dlx = cord(j+1,nx,1)-cord(j,nx,1)
          dly = cord(j+1,nx,2)-cord(j,nx,2)
          press_norm = -press
          ! Normal component
          !
          !           projection on x
          force(j,nx,1) = force(j,nx,1)-0.5*press_norm*dly
          force(j+1,nx,1) = force(j+1,nx,1)-0.5*press_norm*dly

          !           projection on y
          force(j,nx,2) = force(j,nx,2)+0.5*press_norm*dlx
          force(j+1,nx,2) = force(j+1,nx,2)+0.5*press_norm*dlx

          balance(j,nx,1) = 1.e+17
          balance(j+1,nx,1) = 1.e+17

          rogh = rogh +dP
      enddo

  endif

  !----------------------------------
  ! APPLY  STATIC STRESSES:
  !----------------------------------
  do i=1,nopbmax

      ii1 = nopbou(i,1)
      ii2 = nopbou(i,2)
      jj1 = nopbou(i,3)
      jj2 = nopbou(i,4)
      dlx = cord(jj2,ii2,1)-cord(jj1,ii1,1)
      dly = cord(jj2,ii2,2)-cord(jj1,ii1,2)

      !
      ! Normal component
      !

      s_normal = bcstress(i,1)
      !           projection on x
      force(jj1,ii1,1) = force(jj1,ii1,1)-0.5*s_normal*dly
      force(jj2,ii2,1) = force(jj2,ii2,1)-0.5*s_normal*dly
      !           projection on z 
      force(jj1,ii1,2) = force(jj1,ii1,2)+0.5*s_normal*dlx
      force(jj2,ii2,2) = force(jj2,ii2,2)+0.5*s_normal*dlx
      !       write(*,*) jj1,jj2,ii1,ii2,s_normal,force(jj1,ii1,1), force(jj2,ii2,1)
      balance(jj1,ii1,1) = 1.e+17
      balance(jj2,ii2,1) = 1.e+17
      !
      ! Shear component
      !

      s_shear  = bcstress(i,2)
      !           projection on x
      force(jj1,ii1,1) = force(jj1,ii1,1)+0.5*s_shear*dlx
      force(jj2,ii2,1) = force(jj2,ii2,1)+0.5*s_shear*dlx
      !           projection on z 
      force(jj1,ii1,2) = force(jj1,ii1,2)+0.5*s_shear*dly
      force(jj2,ii2,2) = force(jj2,ii2,2)+0.5*s_shear*dly

      balance(jj1,ii1,2) = 1.e+17
      balance(jj2,ii2,2) = 1.e+17

      !       if (i_sl.eq.1) then
      !       s_shearo  = bcstress(i,3)
      !           projection on x
      !       force(nn1,3) = force(nn1,3)+0.5*s_shearo*dlx
      !       force(nn2,3) = force(nn2,3)+0.5*s_shearo*dlx
      !       write(*,*) bcstress(i,3) 
      !       balance(nn1,3) = 1.e+17
      !       balance(nn2,3) = 1.e+17
      !       endif
  enddo

  return
end subroutine bc_update
