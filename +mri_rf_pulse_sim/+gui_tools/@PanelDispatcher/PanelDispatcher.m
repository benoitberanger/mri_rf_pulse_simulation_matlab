classdef PanelDispatcher < handle
    
    properties
        
        x_margin = 0.01
        x_width
        
        y_margin = 0.01
        y_inputVect
        y_vectLength
        y_vectTotal
        y_unitHeight
        
        y_count
        
    end % props
    
    
    methods
        
        %------------------------------------------------------------------
        %- Constructor
        function self = PanelDispatcher(y_inputVect)
            
            self.x_width = 1 - 2*self.x_margin;
            
            if nargin == 0
                return
            end
            
            self.y_inputVect  = y_inputVect;
            self.y_vectLength = length(self.y_inputVect);
            self.y_vectTotal  = sum(self.y_inputVect);
            self.y_unitHeight = ( 1 - (self.y_margin*(self.y_vectLength + 1)) ) / self.y_vectTotal ;
            
            self.y_count = self.y_vectLength + 1;
            
        end % function
        
        %------------------------------------------------------------------
        function value = x_pos(self)
            value = self.x_margin;
        end
        
        %------------------------------------------------------------------
        function next(self, value)
            if nargin < 2
                value = -1;
            end
            self.y_count = self.y_count + value;
        end
        
        %------------------------------------------------------------------
        function value = y_height(self)
            value = self.y_unitHeight * self.y_inputVect(self.y_count);
        end
        
        %------------------------------------------------------------------
        function value = y_pos(self)
            value = self.y_unitHeight*sum(self.y_inputVect(1:self.y_count-1)) + self.y_margin *(self.y_count);
        end
        
    end % meths
    
end % class
