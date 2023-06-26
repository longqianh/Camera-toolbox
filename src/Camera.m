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

