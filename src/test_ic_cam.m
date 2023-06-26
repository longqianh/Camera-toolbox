clc;close all;clear;
%% Initialization
cam_para.ROI=[0 0 600 480];
cam_para.exposure=0.0001;
cam_para.gain=0;
cam_para.trigger_frames=1;
cam_para.frame_rate = 100; 
cam_para.frame_delay = 5e-2;
cam_para.vidtype= 'Y16 (752x480)'; %'Y16 (752x480)';
cam=ICCamera(cam_para);
cam.preview();
%% Check camera info
cam.info();

%% Set ROI
cam.setROI([256,202,170,170]);
%% Set frame rate
% NOTE: if framerate < max framerate, the exposure time will change
cam.setFrameRate(200);
%% Set exposure time
% NOTE: if 1/exposure time < max framerate, the framerate will change
cam.setExposure(1e-4);

%% Capture and save
% savePath="test_cam.tiff";
img=cam.capture();
img=im2uint16(img);
figure('Color','White');
imshow(img,[]);colorbar;
% imwrite(img,savePath);
% cam.close();

%% Trigger mode
% cam.trigger_on();
% cam.info();

%% Unload
cam.free();