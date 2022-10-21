function [Micx,Micy,Micz]=rect_angle_center2(nx,ny,d,ang_ele,ang_ami,micx0,micy0,micz0)

% Function rect_angle_center2
% INPUT (mandatory):
% nx=8; %Microphone number is nx * ny
% ny=4; %
% d=0.04;% Distance between microphones
% micx0=0;
% micy0=0;
% micz0=8.15; %Position of the center of the array
% ang_ele=91*pi/180; %Elevation of the array 
% ang_ami=-2.3*pi/180; %Azimuth of the array 
% OUTPUT:
%Micx: 32 * 1: x position of microphones
%Micy: 32 * 1: y position of microphones
%Micz: 32 * 1: z position of microphones

Micx=zeros(1,nx*ny);
Micy=zeros(1,nx*ny);
Micz=zeros(1,nx*ny);
x_all=d*(nx-1);
y_all=d*(ny-1);

for ix=1:nx
for iy=1:ny
    
    Micx(ix+(iy-1)*nx)=-(iy-1)*d+y_all/2;
    Micy(ix+(iy-1)*nx)=-(ix-1)*d+x_all/2;
    Micz(ix+(iy-1)*nx)=Micx(ix+(iy-1)*nx)*sin(ang_ele);
    Micx(ix+(iy-1)*nx)=Micx(ix+(iy-1)*nx)*cos(ang_ele);

   tempx=Micx(ix+(iy-1)*nx);
   tempy=Micy(ix+(iy-1)*nx);
   Micx(ix+(iy-1)*nx)=tempy*sin(ang_ami)+tempx*cos(ang_ami);
   Micy(ix+(iy-1)*nx)=tempy*cos(ang_ami)-tempx*sin(ang_ami);   
   
end
end

Micx=Micx.'+micx0;
Micy=Micy.'+micy0;
Micz=Micz.'+micz0;



