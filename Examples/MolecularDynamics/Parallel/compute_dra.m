function [potential kinetic Force1]=compute_dra(Np, Nd, Poss1, Vel1, Mass1, Force2);
%   Purpose: COMPUTE computes the forces and energies.

%   Discussion:
%     The computation of forces and energies is fully parallel.
%     The potential function V(X) is a harmonic well which smoothly
%     saturates to a maximum value at PI/2:
% 
%       v(x) = ( sin ( min ( x, PI2 ) ) )**2
% 
%     The derivative of the potential is:
% 
%       dv(x) = 2.0 * sin ( min ( x, PI2 ) ) * cos ( min ( x, PI2 ) )
%             = sin ( 2.0 * min ( x, PI2 ) )
% 
%   Licensing:
% 
%     This code is distributed under the GNU LGPL license. 
% 
%   Modified:
% 
%     21 November 2007
%        Matlab development 19 August 2015 
%     
% 
%   Author:
% 
%     Original FORTRAN77 version by Bill Magro.
%     C version by John Burkardt.
%     Matlab Version Ronal Muresano and Ivano Azzini 
% 
%   Parameters:
%     Input: 
%            Np: Number of particles.
%            Nd: Number of spatial dimensions.
%            pos[ND*NP]: Position of each particle.
%            vel[ND*NP]: Velocity of each particle.
%            mass: Mass of each particle.
%     Output 
%
%           F[ND*NP]:Forces.
%           Pot: Total potential energy.
%           Kin: Total kinetic energy.
%
PI2 = 3.141592653589793 / 2.0;
pe=0;
ke=0;
rip=zeros(Nd);
    
startFor=1;
endFor=Np;
index=1;
[startFor endFor myoutput]=DRAGONFLY_Parallel_Start('k','startFor','endFor');
for k=startFor: endFor
     Force1(1:3,index)=0;
     for j=1:Np,
        if (k~=j)
            [d , rij]=dist(Nd, Poss1(:,k),Poss1(:,j));
            if d<PI2
                d2=d;
            else
                d2=PI2;
            end
            pe= pe + 0.5 * sin(d2)^2;
            for i=1:Nd
                Force1(i, index)= Force1(i, index) - (rij(i)*sin(2*d2))/d;
            end
        end
    end
    for i=1:1<Nd
        ke=ke +Vel1(i,k)*Vel1(i,k);
    end
    index=index+1;
end
DRAGONFLY_Parallel_Block_End(myoutput,'Force1','1','pe','1', 'ke','1');

ke1=sum(ke)*0.5*Mass1;
potential=sum(pe);
kinetic =ke1;
end

