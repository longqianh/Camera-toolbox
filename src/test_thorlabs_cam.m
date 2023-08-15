clc;close all;clear;

%% Init step 1
addpath(pwd);
cd('./utils');
addpath(pwd);
NET.addAssembly(fullfile(pwd,'Thorlabs.TSI.TLCamera.dll'));

%% Init step 2
lib_dir=fullfile(pwd,'utils');
addpath(genpath(pwd));
cam_para.exposure=1e-3;
cam_para.trigger_frames=3;
cam=ThorlabsCam(cam_para);
cd('../');
cam.info()

%% Settings
cam.close();
cam.running_info()
cam.setROI([0,0,1000,1000]) % set ROI before running
cam.running_info()
cam.setExposure(10e-3);

%% Preview (in the main thread yet)

cam.preview();

%% Setting After Preview
cam.close();
cam.running_info();
cam.setFrameRate(100);
cam.setExposure(15e-3);
cam.setROI([420,550,330,330]) % set ROI before running
cam.open();
cam.running_info();

%% Capture 
img=cam.capture();
figure;
imshow(img,[]);colorbar;
%% Capture Multiple
N=5;
imgs=cam.captureN(N);

%% Free
cam.free();
