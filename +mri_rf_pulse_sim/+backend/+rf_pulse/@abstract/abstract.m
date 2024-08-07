classdef (Abstract) abstract < mri_rf_pulse_sim.backend.base_class

    properties (GetAccess = public, SetAccess = public)
        n_points        mri_rf_pulse_sim.ui_prop.scalar                    % []  number of points defining the pulse
        duration        mri_rf_pulse_sim.ui_prop.scalar                    % [s] pulse duration
        slice_thickness mri_rf_pulse_sim.ui_prop.scalar                    % [m] slice width
        gz_rewinder     mri_rf_pulse_sim.ui_prop.bool                      % add a selective selective gradient rewinder automatically
        time           (1,:) double                                        % [s] time vector
        B1             (1,:) double                                        % [T] complex waveform of the pulse
        GZ             (1,:) double                                        % [T/m] slice gradient
        gamma          (1,1) double {mustBePositive} = mri_rf_pulse_sim.get_gamma('1H') % [rad/T/s] gyromagnetic ration
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        FM              mri_rf_pulse_sim.ui_prop.scalar                    % [Hz]    frequency modulation -> its the derivation of the phase(t)
        B1max           mri_rf_pulse_sim.ui_prop.scalar                    % [T]     max value of magnitude(t)
        GZmax           mri_rf_pulse_sim.ui_prop.scalar                    % [T/m]   max value of  gradient(t)
        GZavg           mri_rf_pulse_sim.ui_prop.scalar                    % [T/m]   average value of gradient(t) -> used for slice thickness
        tbwp            mri_rf_pulse_sim.ui_prop.scalar                    % []      time-bandwidth product -> in the literature, it represents a "quality" factor
        energy          mri_rf_pulse_sim.ui_prop.scalar                    % []      ~Joules (J)
        power           mri_rf_pulse_sim.ui_prop.scalar                    % []      ~Watts  (W) !! average power (not instantaneous)
        B1rms           mri_rf_pulse_sim.ui_prop.scalar                    % [T]     B1 Root Mean Square
        gradB1max       mri_rf_pulse_sim.ui_prop.scalar                    % [T/s]   max(dB1/dt)
        gradGZmax       mri_rf_pulse_sim.ui_prop.scalar                    % [T/m/s] max(dGZ/dt)
    end % props

    methods % no attribute for dependent properties
        function value = get.FM       (self); value = gradient(self.phase,self.time) / (2*pi);                 end

        function value = get.B1max    (self); value = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='B1max'    , value=max(abs(self.B1))                                      , unit='µT'     , scale=1e06); end
        function value = get.GZmax    (self); value = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='GZmax'    , value=max(abs(self.GZ))                                      , unit='mT/m'   , scale=1e03); end
        function value = get.GZavg    (self); value = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='GZavg'    , value=2*pi*self.bandwidth / (self.gamma*self.slice_thickness), unit='mT/m'   , scale=1e03); end
        function value = get.tbwp     (self); value = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='tbwp'     , value=self.duration * self.bandwidth                                                     ); end
        function value = get.energy   (self); value = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='energy'   , value=trapz(self.time,self.magnitude.^2)                     , unit='fJ'     , scale=1e15); end
        function value = get.power    (self); value = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='power'    , value=self.energy/self.duration                              , unit='pW'     , scale=1e12); end
        function value = get.B1rms    (self); value = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='B1rms'    , value=sqrt(self.power)                                       , unit='µT'     , scale=1e06); end
        function value = get.gradB1max(self); value = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='gradB1max', value=max(gradient(self.magnitude,self.time))                , unit='µT/ms'  , scale=1e03); end
        function value = get.gradGZmax(self); value = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='gradGZmax', value=max(gradient(self.GZ       ,self.time))                , unit='mT/m/ms'            ); end
    end % meths

    methods (Access = public)

        % constructor
        function self = abstract(varargin)
            self.n_points        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_points'       , value=256                             );
            self.duration        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='duration'       , value=  5 * 1e-3, unit='ms', scale=1e3);
            self.slice_thickness = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='slice_thickness', value=  4 * 1e-3, unit='mm', scale=1e3);
            self.gz_rewinder     = mri_rf_pulse_sim.ui_prop.bool  (parent=self, name='gz_rewinder'    , value=false     , text='GZrewinder', visible='off');
        end

        % EZ maths
        function out = real     (self); out = real (self.B1); end
        function out = imag     (self); out = imag (self.B1); end
        function out = abs      (self); out = abs  (self.B1); end
        function out = angle    (self); out = unwrap(angle(self.B1)); end
        % EZ maths aliases
        function out = mag      (self); out = self.abs()    ; end
        function out = magnitude(self); out = self.abs()    ; end
        function out = pha      (self); out = self.angle()  ; end
        function out = phase    (self); out = self.angle()  ; end

        % plot the shape of the pulse : real, imag, abs, angle, FM, GZ
        % it will be plotted in a new figure or a pre-opened figure/uipanel
        function varargout = plot(self, container)
            self.assert_nonempty_prop({'time', 'B1', 'GZ'})

            if ~exist('container','var')
                container = figure('NumberTitle','off','Name',self.summary());
            end

            lineprop_B1  = {                                          'LineStyle','-', 'LineWidth',2.0                        };
            lineprop_ref = {[self.time(1) self.time(end)]*1e3, [0 0], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5]};

            a(1) = subplot(6,1,1,'Parent',container);
            hold(a(1), 'on')
            plot(a(1), self.time*1e3, self.real()*1e6, lineprop_B1{:}, 'Color', [163 207 244]/255)
            a(1).XTickLabel = {};
            a(1).YLabel.String = 'Re [µT]';
            a(1).YLabel.Rotation = 0;
            a(1).YLabel.HorizontalAlignment = 'right';
            plot(a(1), lineprop_ref{:})
            axis(a(1),'tight')

            a(2) = subplot(6,1,2,'Parent',container);
            hold(a(2), 'on')
            plot(a(2), self.time*1e3, self.imag()*1e6, lineprop_B1{:}, 'Color', [163 207 244]/255)
            a(2).XTickLabel = {};
            a(2).YLabel.String = 'Im [µT]';
            a(2).YLabel.Rotation = 0;
            a(2).YLabel.HorizontalAlignment = 'right';
            plot(a(2), lineprop_ref{:})
            axis(a(2),'tight')

            a(3) = subplot(6,1,3,'Parent',container);
            hold(a(3), 'on')
            plot(a(3), self.time*1e3, self.abs()*1e6, lineprop_B1{:}, 'Color', [100 182 229]/255)
            a(3).XTickLabel = {};
            a(3).YLabel.String = 'Mag [µT]';
            a(3).YLabel.Rotation = 0;
            a(3).YLabel.HorizontalAlignment = 'right';
            plot(a(3), lineprop_ref{:})
            axis(a(3),'tight')

            a(4) = subplot(6,1,4,'Parent',container);
            hold(a(4), 'on')
            plot(a(4), self.time*1e3, self.angle()/(2*pi), lineprop_B1{:}, 'Color', [100 182 229]/255)
            a(4).XTickLabel = {};
            a(4).YLabel.String = 'Pha x2π[rad]';
            a(4).YLabel.Rotation = 0;
            a(4).YLabel.HorizontalAlignment = 'right';
            plot(a(4), lineprop_ref{:})
            axis(a(4),'tight')

            a(5) = subplot(6,1,5,'Parent',container);
            hold(a(5), 'on')
            plot(a(5), self.time*1e3, self.FM(), lineprop_B1{:}, 'Color', [115 107 172]/255)
            a(5).XTickLabel = {};
            a(5).YLabel.String = 'FM [Hz]';
            a(5).YLabel.Rotation = 0;
            a(5).YLabel.HorizontalAlignment = 'right';
            plot(a(5), lineprop_ref{:})
            axis(a(5),'tight')

            a(6) = subplot(6,1,6,'Parent',container);
            hold(a(6), 'on')
            plot(a(6), self.time*1e3, self.GZ*1e3, lineprop_B1{:}, 'Color', [132 190 99]/255)
            a(6).XLabel.String = 'time (ms)';
            a(6).YLabel.String = 'GZ (mT/m)';
            a(6).YLabel.Rotation = 0;
            a(6).YLabel.HorizontalAlignment = 'right';
            plot(a(6), lineprop_ref{:})
            axis(a(6),'tight')

            linkaxes(a,'x');

            if nargout
                varargout{1} = container;
            end
        end

        function callback_update(self, ~, ~)
            self.notify_parent();
        end

        function phase = freq2phase(self, freq)
            phase = cumtrapz(self.time, freq);
        end

        function init_base_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar( ...
                container, ...
                [self.n_points, self.duration, self.slice_thickness], ...
                [0.00 0.00 0.60 1.00]...
                );
            self.gz_rewinder.add_uicontrol(container, [0.60 0.60 0.40 0.40])
        end % fcn

        function displayRep = compactRepresentationForSingleLine(self,displayConfiguration,width)
            txt = sprintf('%s', self.summary());
            displayRep = widthConstrainedDataRepresentation(self,displayConfiguration,width,...
                StringArray=txt,AllowTruncatedDisplayForScalar=true);
        end % fcn

        function add_gz_rewinder(self, status)
            self.gz_rewinder.visible = "on";
            if nargin == 1, status = self.gz_rewinder.get(); end
            if ~status    , return                         , end

            n_new_points = round(self.n_points/2);
            self.time = [self.time linspace(self.time(end), self.time(end)+self.duration/2, n_new_points)];
            self.B1   = [self.B1   zeros(1,n_new_points)                                                 ];
            self.GZ   = [self.GZ   -self.GZ(n_new_points+1:end)                                          ];
        end % fcn

    end % meths

    methods (Access = protected)

        function assert_nonempty_prop(self, prop_list)
            assert(ischar(prop_list) || iscellstr(prop_list)) %#ok<ISCLSTR>
            prop_list = cellstr(prop_list); % force cellstr
            for p = 1 : numel(prop_list)
                assert( ~isempty(self.(prop_list{p})), 'empty %s', prop_list{p} )
            end
        end % fcn

    end % meths

    % =====================================================================
    % ABSTRACT stuff : need to be implemented in subclass

    properties (Abstract, GetAccess = public, SetAccess = protected)
        bandwidth (1,1) double                                             % [Hz]
    end % props

    methods (Abstract)
        % all abstract methods can be "empty" and do nothing
        % but they MUST be defined
        generate                                                           % generate pulse shape using input parameters
        init_specific_gui                                                  % draw UI elements
        summary                                                            % print summary text
    end % meths

end % class
