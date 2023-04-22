classdef ThorlabsCam<Camera
    properties
        trigger_on = 0
    end

    properties(Access=private)
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
            imageData2D = reshape(imageData, [imageHeight,imageWidth]);
            
        end
    end

    methods
        function obj=ThorlabsCam(cam_para)
            obj=obj@Camera(cam_para);
            obj.init();
        end
        
        function init(obj)
            
            obj.tlCameraSDK = Thorlabs.TSI.TLCamera.TLCameraSDK.OpenTLCameraSDK;
            serialNumbers = obj.tlCameraSDK.DiscoverAvailableCameras;
            obj.device_id = serialNumbers.Item(0);
            obj.tlCamera = obj.tlCameraSDK.OpenCamera(obj.device_id,false);

        end
        
        function info(obj)
            disp("Thorlabs Camera.\n");
        end

        function setROI(obj,val)
            a=1
        end
        function setExposure(obj,val)
            a=1
        end
        function setFrameRate(obj,val)
            a=1
        end
        function img=capture(obj,savePath)
            
            imageFrame = obj.tlCamera.GetPendingFrameOrNull;
            if ~isempty(imageFrame)
                img=obj.processFrameData(imageFrame);
                save(savePath, 'img')
            else
                disp("Empty Frame\n");
            end
        end
        
        function setTriggerFrames(obj,val)
            a=1
        end

     

        function preview(obj)
            if ~obj.trigger_on
                obj.tlCamera.OperationMode = Thorlabs.TSI.TLCameraInterfaces.OperationMode.SoftwareTriggered;
                obj.tlCamera.Arm;
                obj.tlCamera.IssueSoftwareTrigger;
                obj.trigger_on=1;
            end    
            numberOfFramesToAcquire = 100000;
            frameCount = 0;
            figure('Color','White','Name',"Preview",'MenuBar','none','ToolBar','none');
            while frameCount < numberOfFramesToAcquire
                % Check if image buffer has been filled
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
        function close(obj)
            obj.trigger_on = 0;
            close all;
        end

        function free(obj)
            if obj.trigger_on
                obj.tlCamera.Disarm;
                obj.tlCamera.Dispose;
                fprintf("Trigger disopoed.\n");
            end

            obj.tlCameraSDK.Dispose;
            fprintf("SDK disposed.\n");
            
        end

    end
end