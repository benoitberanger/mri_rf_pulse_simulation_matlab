classdef (Abstract) base_class < handle & matlab.mixin.CustomCompactDisplayProvider

    properties (GetAccess = public,  SetAccess = public, Hidden)
        app                                            % pointer to the app
        parent                                                             % pointer to an unknown object (unknown type)
        listener_update        event.listener
        listener_update_app    event.listener
        listener_update_parent event.listener
    end % props

    events
        update
        update_app
        update_parent
    end % evt

    methods(Access = public)

        % constructor
        function self = base_class()
            self.listener_update        = addlistener(self, 'update'       , @self.callback_update);
            self.listener_update_app    = addlistener(self, 'update_app'   , @self.notify_app     );
            self.listener_update_parent = addlistener(self, 'update_parent', @self.notify_parent  );
        end % fcn

    end % meths

    methods(Access = public)

        function notify_parent(self,~,~)
            if ~isempty(self.parent)
                notify(self.parent,'update')
            end
        end % fcn

        function notify_app(self,~,~)
            if ~isempty(self.app)
                notify(self.app,'update')
            end
        end % fcn

    end % meths

end % class
