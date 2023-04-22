clc;close all;clear;
addpath(pwd);
cd('./utils');
addpath(pwd);
NET.addAssembly(fullfile(pwd,'Thorlabs.TSI.TLCamera.dll'));

%%

lib_dir=fullfile(pwd,'utils');
addpath(genpath(pwd));
cam_para.exposure=20000;
cam_para.frame_rate=30;
cam_para.trigger_frames=3;
cam=ThorlabsCam(cam_para);
cd('../');
%%
cam.preview();

%%
img=cam.capture('test.tiff');
figure;
imshow(img,[]);colorbar;
%% Free
cam.free();
