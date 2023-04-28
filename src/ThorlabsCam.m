classdef ThorlabsCam<Camera
    properties

    end

    properties (Access=private)
        tlCameraSDK
        tlCamera
    end

    methods(Static)
        function imageData2D=processFrameData(imageFrame)
            % Get the image data as 1D uint16 array
            imageData = uint16(imageFrame.ImageData.ImageData_monoOrBGR);

            % TODO: custom image processing code goes here
            imageHeight = imageFrame.ImageData.Height_pixels;
            imageWidth = imageFrame.ImageData.Width_pixels;
            imageData2D = reshape(imageData, [imageWidth,imageHeight])';
            
        end
    end

    methods
        function obj=ThorlabsCam(cam_para)
            obj=obj@Camera(cam_para);
            obj.init();
             
            obj.ROI=[obj.tlCamera.ROIAndBin.ROIOriginX_pixels,...
                obj.tlCamera.ROIAndBin.ROIOriginY_pixels,...
                obj.tlCamera.ROIAndBin.ROIWidth_pixels,...
                obj.tlCamera.ROIAndBin.ROIHeight_pixels];

            if ~isempty(obj.exposure)
                obj.setExposure(obj.exposure);
            end
            
            if ~isempty(obj.trigger_frames)
                obj.setTriggerFrames(obj.trigger_frames);
            end
            
%             if ~isempty(obj.frame_rate)
%                 obj.setFrameRate(obj.frame_rate);
%             end
            
            if ~isempty(obj.ROI)
                obj.setROI(obj.ROI);
            end
        end
        
        function init(obj)
            
            obj.tlCameraSDK = Thorlabs.TSI.TLCamera.TLCameraSDK.OpenTLCameraSDK;
            serialNumbers = obj.tlCameraSDK.DiscoverAvailableCameras;
            obj.device_id = serialNumbers.Item(0);
            obj.tlCamera = obj.tlCameraSDK.OpenCamera(obj.device_id,false);
           
        end
        
        function info(obj)
            fprintf("Thorlabs Camera.\n");
            fprintf("Camera Model: %s\n",obj.tlCamera.Model);
            fprintf("Camera Pixel Width: %.2f um\n",obj.tlCamera.SensorPixelWidth_um);
            fprintf("Camera Max Frame Rate: %.2f fps\n",obj.tlCamera.FrameRateControlValue_fps);
            fprintf("Camera Bit Depth: %d\n",obj.tlCamera.BitDepth);
            fprintf("Camera Sensor Readout Time: %.2f ms\n",1e-6*obj.tlCamera.SensorReadoutTime_ns)
            fprintf("Camera OperationMode: %s\n",obj.tlCamera.OperationMode);
            fprintf("Camera Full Frame Size: [%d,%d]\n",obj.tlCamera.SensorHeight_pixels,obj.tlCamera.SensorWidth_pixels);
        end

        function running_info(obj)
            fprintf("Camera ROI: [%d,%d,%d,%d]\n",obj.ROI);
            fprintf("Camera Frame Rate: %.2f fps\n",1e6/obj.tlCamera.FrameTime_us);
            fprintf("Camera Exposure Time: %.2f ms\n",1e-3*obj.tlCamera.ExposureTime_us);
            fprintf("Camera Frames Per Trigger: %d\n",obj.tlCamera.FramesPerTrigger_zeroForUnlimited);
        end

        function setROI(obj,val)
            obj.tlCamera.ROIAndBin.ROIOriginX_pixels=val(1);
            obj.tlCamera.ROIAndBin.ROIOriginY_pixels=val(2);
            obj.tlCamera.ROIAndBin.ROIWidth_pixels=val(3);
            obj.tlCamera.ROIAndBin.ROIHeight_pixels=val(4);
            obj.ROI=val;
        end
        

        function setExposure(obj,val)
            % input val: [s]
            obj.tlCamera.ExposureTime_us=1e6*val;
            obj.exposure=obj.tlCamera.ExposureTime_us;
        end

        function setFrameRate(obj,val)
            % Bug here
            obj.tlCamera.ExposureTime_us=1/val*1e6-obj.tlCamera.SensorReadoutTime_ns*1e-3;
            obj.frame_rate=1e6/obj.tlCamera.FrameTime_us;
        end


        function setTriggerFrames(obj,val)
            obj.tlCamera.FramesPerTrigger_zeroForUnlimited=floor(val);
            obj.trigger_frames=floor(val);
        end

   

        function open(obj)
            if ~obj.tlCamera.IsArmed
                obj.tlCamera.Arm;
            end    
        end
        
        function trigger_on(obj,mode)
            arguments
                obj
                mode="soft"
            end
            if mode=="soft"
                obj.tlCamera.OperationMode = Thorlabs.TSI.TLCameraInterfaces.OperationMode.SoftwareTriggered;
                obj.tlCamera.IssueSoftwareTrigger;
            end

        end

        function preview(obj)
            obj.close();
            obj.setTriggerFrames(0);
            obj.open();
            obj.trigger_on();

%             addlistener(obj.tlCamera.OnImageFrameAvailable,"DataAvailable",obj.tlCamera.GetPendingFrameOrNull);
            numberOfFramesToAcquire = 100000;
            frameCount = 0;
            figure('Color','White','Name',"Preview",'MenuBar','none','ToolBar','none');
            while frameCount < numberOfFramesToAcquire
%                 Check if image buffer has been filled
                if (obj.tlCamera.NumberOfQueuedFrames > 0)
                    
                    % If data processing in Matlab falls behind camera image
                    % acquisition, the FIFO image frame buffer could overflow,
                    % which would result in missed frames.
                    if (obj.tlCamera.NumberOfQueuedFrames > 1)
                        disp(['Data processing falling behind acquisition. ' num2str(obj.tlCamera.NumberOfQueuedFrames) ' remains']);
                    end
                    
                    % Get the pending image frame.
                    imageFrame = obj.tlCamera.GetPendingFrameOrNull;
                    if ~isempty(imageFrame)
                        frameCount = frameCount + 1;
                        
                        disp(['Image frame number: ' num2str(imageFrame.FrameNumber)]);
                        imageData2D=obj.processFrameData(imageFrame);
                        imshow(im2double(imageData2D),[]);colormap("gray");
%                         imagesc(imageData2D), colormap(gray);
                    end
                    
                    % Release the image frame
                    delete(imageFrame);
                end
                drawnow;
            end
        end

        function imgs=captureN(obj,N)
            obj.trigger_on();
            n=0;
            imgs=cell(N,1);
            while n<N  
                imageFrame = obj.tlCamera.GetPendingFrameOrNull;
                if ~isempty(imageFrame)
                    n=n+1;
                    img=obj.processFrameData(imageFrame);
                    imgs{n}=img;
                end
            end
        end

        function img=capture(obj,savePath)
            
            obj.trigger_on();
            imageFrame = obj.tlCamera.GetPendingFrameOrNull;
            if ~isempty(imageFrame)
                img=obj.processFrameData(imageFrame);
                if nargin==2
                    save(savePath, 'img');
                end
            else
                fprintf("Empty Frame\n");
            end
            end

        function close(obj)
            if obj.tlCamera.IsArmed
                obj.tlCamera.Disarm;
            end
            close all;
        end

        function free(obj)
            if obj.tlCamera.IsArmed
                obj.tlCamera.Disarm;
                obj.tlCamera.Dispose;
                fprintf("Trigger disopoed.\n");
            end

            obj.tlCameraSDK.Dispose;
            fprintf("SDK disposed.\n");
            
        end

    end
end