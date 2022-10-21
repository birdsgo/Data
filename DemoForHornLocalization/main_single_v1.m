clc;
close all;
clear ;

%DEMO_SRP-PHAT_for Whistling Vehicle Localization
%
% Demonstration of SRP-PHAT-based Whistling Vehicle Localization
%
% To use the database provided by Audio and Speech Signal Processing in
% Institute of Acoustics, Chinese Academy of Sciences:
% 1. Download the database from github: https://github.com/birdsgo/test
% 2. Put the 4 folders named Task 1-4 corresponding to 4 tasks in the folder named Data
% 3. Put the 4 folders named Type 1-4 corresponding to 4 types of vehicle whistle durations in the 4 folder named Task 1-4.
% 4. Set the true position information of the whistling vehicle and the type of vehicle whistle duration.
% 5. Set the sample index.
% 6. Run the demo direrctly.

%
% Reference:
% Fangjie Zhang, Jian Li, Weixin Meng, Xiaodong Li, and Chengshi Zheng. A
% vehicle whistle database for evaluation of outdoor acoustic source
% localization and tracking using an intermediate-size microphone array.
% Applied Acoustics, in Revision.
%
% Chengshi Zheng (cszheng@mail.ioa.ac.cn)
% Institute of Acoustics, Chinese Academy of Sciences
% No. 21 North 4th Ring Road,
% Haidian District, 100190 Beijing, China

addpath(genpath('lib'));
%% single 
ix=20;
iy=6;
itype=1;
isample=1;
[x,fs]=audioread(['.\Data\Task1\Type',num2str(itype),'\x',num2str(ix),'y',num2str(iy),'_sample',num2str(isample),'.wav']);
nsrce                      = 1;          % Number of sources to be detected
show                       = 1;      % 0: Display one location found  1:Display locations found of all Frames
model                      = 1;      % 0：Coarse Scanning 1:Coarse Scanning+ Fine Scanning
%% single_move
% nsrce                      = 1;          % Number of sources to be detected
% show                       = 1;      % 0: Display one location found 1:Display locations found of all Frames
% model                      = 1;      % 0：Coarse Scanning 1:Coarse Scanning+ Fine Scanning
%% dual
% ix1=50;
% iy1=4;
% ix2=40;
% iy2=0;
% itype=4;
% isample=2;
% nsrce                      = 2;          % Number of sources to be detected
% show                       = 0;      % 0: Display one location found
% model                      = 0;      % 0：Coarse Scanning 
%% Microphone array parameters
% Warning: All microphones are supposed to be omnidirectionnals !
isArrayMoving   = 0;  % The microphone array is not moving
subArray        = []; % []: all microphones are used
sceneTimeStamps = []; % Both array and sources are statics => no time stamps

%% MBSS Locate core Parameters
% 定位参数

nx=8; %Microphone number is nx * ny (rectangle array)
ny=4; %
d=0.04;% Distance between microphones
micx0=0;
micy0=0;
micz0=8.15; %Position of the center of the array
ang_ele=91*pi/180; %Elevation of the array 
ang_ami=-2.3*pi/180; %Azimuth of the array 
% localization method
angularSpectrumMeth        = 'GCC-PHAT-BaseXY'; %  Local angular spectrum method {'GCC-PHAT-BaseXY' 'MUSIC-BaseXY'}

pooling                    = 'max';      %  Pooling method {'max' 'sum'}
applySpecInstNormalization = 0;          % 1: Normalize instantaneous local angular spectra - 0: No normalization
% Search space
azBound                    = [-179 180]; % Azimuth search boundaries 
elBound                    = [-90 90];   % Elevation search boundaries 
gridRes                    = 1;          % Resolution  of the global 3D reference system {azimuth,elevation}
alphaRes                   = 5;          % Resolution  of the 2D reference system defined for each microphone pair

% Multiple sources parameters

minAngle                   = 10;         % Minimum angle between peaks
% Moving sources parameterss
blockDuration_sec          = [];         % Block duration in seconds (default []: one block for the whole signal)
blockOverlap_percent       = [];         % Requested block overlap in percent (default []: No overlap) - is internally rounded to suited values
% Wiener filtering
enableWienerFiltering      = 0;          % 1: Process a Wiener filtering step in order to attenuate / emphasize the provided excerpt signal into the mixture signal. 0: Disable Wiener filtering
wienerMode                 = [];         % Wiener filtering mode {'[]' 'Attenuation' 'Emphasis'}
wienerRefSignal            = [];         % Excerpt of the source(s) to be emphasized or attenuated
% Display results
specDisplay                = 1;          % 1: Display angular spectrum found and sources directions found - 0: No display
% Other parameters
speedOfSound               = 345;        % Speed of sound (m.s-1) - typical value: 343 m.s-1 (assuming 20 in the air at sea level)
fftSize_sec                = [];         % FFT size in seconds (default []: 0.064 sec)
freqRange                  = [];         % Frequency range (pair of values in Hertz) to aggregate the angular spectrum : [] means that all frequencies will be used
% Debug
angularSpectrumDebug       = 0;          % 1:Enable additional plots to debug the angular spectrum aggregation

%% New parameters of carhorn
xBound                     = [0,55]; % x search boundaries 
yBound                     = [-2,10]; % y search boundaries 
iz                         = 0.3;  % Height of plane
xRes                       = 1;          % Resolution  of x (Coarse Scanning)
yRes                       = 1;          % Resolution  of y (Coarse Scanning)
xRes2                       = 0.25;          % Resolution  of x (Fine scanning)
yRes2                      = 0.25;          % Resolution  of y (Fine scanning)
minX                       = 2;          % Minimum x between peaks
minY                       = 1.5;    % Minimum y between peaks

%%  New struct:carhorn
carhorn = struct;
carhorn.xBound=xBound;
carhorn.yBound=yBound;
carhorn.iz=iz;
carhorn.xRes=xRes;
carhorn.yRes=yRes;
carhorn.xRes2=xRes2;
carhorn.yRes2=yRes2;
carhorn.minX=minX;
carhorn.minY=minY;
carhorn.show = show;        
carhorn.model = model; 

%% v1: Cartesian coordinates of the microphones (in meters)
[micx,micy,micz]=rect_angle_center2(nx,ny,d,ang_ele,ang_ami,micx0,micy0,micz0);  
micPos=[micx,micy,micz]'; 
%% v1: Compute frequency bins of carhorns & VAD
FreIdx_last_All=[96:192]';  %1500Hz~3000Hz
[x1,FlagforVAD,FreIdx_last_All2]=carhornVAD(x,fs);

carhorn.FlagforVAD=FlagforVAD;
carhorn.FreIdx_last_All=FreIdx_last_All; 
carhorn.FreIdx_last_All2=FreIdx_last_All2;

%% v1: Convert algorithm parameters to MBSS structures
sMBSSParam = MBSS_InputParam2Struct_v1(angularSpectrumMeth,speedOfSound,fftSize_sec,blockDuration_sec,blockOverlap_percent,pooling,azBound,elBound,gridRes,alphaRes,minAngle,nsrce,fs,applySpecInstNormalization,specDisplay,enableWienerFiltering,wienerMode,freqRange,micPos,isArrayMoving,subArray,sceneTimeStamps,angularSpectrumDebug,carhorn);

%% v1: Run the localization
[xEst, yEst, block_timestamps,elaps_time] = MBSS_locate_spec_v1(x,wienerRefSignal,sMBSSParam);  
%% v1: Print the result
Plot_results(xEst.', yEst.',ix,iy,x);
