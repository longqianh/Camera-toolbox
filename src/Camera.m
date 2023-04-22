classdef Camera < handle
    properties
        exposure
        trigger_frames
        frame_rate
        ROI 

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
        obj.exposure=cam_para.exposure;
        obj.frame_rate=cam_para.frame_rate;
        obj.trigger_frames=cam_para.trigger_frames;
        if isfield(cam_para,'ROI')
            obj.ROI=cam_para.ROI;
        end
        
    end

    end
end

