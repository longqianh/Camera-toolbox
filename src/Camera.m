classdef Camera < handle
    properties
        exposure
        trigger_frames
        frame_rate
        ROI 
        frame_delay
    end

    properties (Access=protected)
        device_id
    end

    methods (Abstract)
       info(obj);
       preview(obj);
       close(obj);
       capture(savePath);
       free(obj);
       setROI(obj,val);
       setTriggerFrames(obj,val);
       setExposure(obj,val);
       setFrameRate(obj,val);
       
    end
    
    methods(Static)
        function roi=selectROI(im)
        
            fig=figure('Color','White');
            imshow(im,[]);hold on; 
            
            p1=ginput(1);disp('Choose the left-top point');scatter(p1(1),p1(2),'x');hold on;
            p2=ginput(1);disp('Choose the right-bottom point');scatter(p2(1),p2(2),'x');hold on;
            roi=[p1(1),p2(1),p1(2),p2(2)]; % [x1,x2,y1,y2]
            hold on;
            line([roi(1),roi(1)],[roi(3),roi(4)],'Color','cyan')
            line([roi(2),roi(2)],[roi(3),roi(4)],'Color','cyan')
            line([roi(1),roi(2)],[roi(3),roi(3)],'Color','cyan')
            line([roi(1),roi(2)],[roi(4),roi(4)],'Color','cyan')
            
            roi=[p1(1),p1(2),p2(1)-p1(1),p2(2)-p1(2)];
            disp("Press any key to close");
            pause;
            close(fig);
            % figure;imshow(im(roi(3):roi(4),roi(1):roi(2)))
    
        end

    end

    methods
    function obj=Camera(cam_para)
         
        if isfield(cam_para,'ROI')
            obj.ROI=cam_para.ROI;
        end
        if isfield(cam_para,'exposure')
           obj.exposure=cam_para.exposure;
        end
        if isfield(cam_para,'frame_rate')
           obj.frame_rate=cam_para.frame_rate;
        end
        if isfield(cam_para,'trigger_frames')
            obj.trigger_frames=cam_para.trigger_frames;
        end
        if isfield(cam_para,'frame_delay')
            obj.frame_delay=cam_para.frame_delay;
        end
        
    end

    
    end
end

