classdef (Abstract) abstract < mri_rf_pulse_sim.backend.base_class

    properties (GetAccess = public, SetAccess = public)
        n_points        mri_rf_pulse_sim.ui_prop.scalar                    % []  number of points defining the pulse
        duration        mri_rf_pulse_sim.ui_prop.scalar                    % [s] pulse duration
        slice_thickness mri_rf_pulse_sim.ui_prop.scalar                    % [m] slice width
        time           (1,:) double                                        % [s] time vector
        B1             (1,:) double                                        % [T] complex waveform of the pulse
        GZ             (1,:) double                                        % [T/m] slice gradient
        gamma          (1,1) double {mustBePositive} = mri_rf_pulse_sim.get_gamma('1H') % [rad/T/s] gyromagnetic ration
    end % props

    properties (GetAccess = public, SetAccess = protected)
        FM              (1,:) double                                       % [Hz]  frequency modulation -> its the derivation of the phase(t)
        B1max           (1,1) double                                       % [T]   max value of magnitude(t)
        GZmax           (1,1) double                                       % [T/m] max value of  gradient(t)
        GZavg           (1,1) double                                       % [T/m] average value of gradient(t) -> used for slice thickness
        tbwp            (1,1) double                                       % []    time-bandwidth product
    end % props

    methods % no attribute for dependent properies
        function value = get.B1max(self);           value = max (abs(self.B1)); end
        function value = get.GZmax(self);           value = max (abs(self.GZ)); end
        function value = get.GZavg(self);           value = 2*pi*self.bandwidth / (self.gamma*self.slice_thickness); end
        function value = get.FM(self);              value = gradient(self.phase) ./ gradient(self.time) / (2*pi); end
        function value = get.tbwp(self);            value = self.duration * self.bandwidth; end
    end % meths

    methods (Access = public)

        % constructor
        function self = abstract(varargin)
            self.n_points        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_points'       , value=256                             );
            self.duration        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='duration'       , value=  5 * 1e-3, unit='ms', scale=1e3);
            self.slice_thickness = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='slice_thickness', value=  4 * 1e-3, unit='mm', scale=1e3);
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
        function plot(self, container)
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
            a(1).YLabel.String = 'real (µT)';
            plot(a(1), lineprop_ref{:})
            axis(a(1),'tight')

            a(2) = subplot(6,1,2,'Parent',container);
            hold(a(2), 'on')
            plot(a(2), self.time*1e3, self.imag()*1e6, lineprop_B1{:}, 'Color', [163 207 244]/255)
            a(2).XTickLabel = {};
            a(2).YLabel.String = 'imag (µT)';
            plot(a(2), lineprop_ref{:})
            axis(a(2),'tight')

            a(3) = subplot(6,1,3,'Parent',container);
            hold(a(3), 'on')
            plot(a(3), self.time*1e3, self.abs()*1e6, lineprop_B1{:}, 'Color', [100 182 229]/255)
            a(3).XTickLabel = {};
            a(3).YLabel.String = 'magnitude (µT)';
            plot(a(3), lineprop_ref{:})
            axis(a(3),'tight')

            a(4) = subplot(6,1,4,'Parent',container);
            hold(a(4), 'on')
            plot(a(4), self.time*1e3, self.angle(), lineprop_B1{:}, 'Color', [100 182 229]/255)
            a(4).XTickLabel = {};
            a(4).YLabel.String = 'phase (radian)';
            plot(a(4), lineprop_ref{:})
            axis(a(4),'tight')

            a(5) = subplot(6,1,5,'Parent',container);
            hold(a(5), 'on')
            plot(a(5), self.time*1e3, self.FM(), lineprop_B1{:}, 'Color', [115 107 172]/255)
            a(5).XTickLabel = {};
            a(5).YLabel.String = 'FM (Hz)';
            plot(a(5), lineprop_ref{:})
            axis(a(5),'tight')

            a(6) = subplot(6,1,6,'Parent',container);
            hold(a(6), 'on')
            plot(a(6), self.time*1e3, self.GZ*1e3, lineprop_B1{:}, 'Color', [132 190 99]/255)
            a(6).XLabel.String = 'time (ms)';
            a(6).YLabel.String = 'GZ (mT/m)';
            plot(a(6), lineprop_ref{:})
            axis(a(6),'tight')
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
                [self.n_points, self.duration self.slice_thickness] ...
                );
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

    properties (Abstract, GetAccess = public, SetAccess = protected, Dependent)
        bandwidth (1,1) double                                             % [Hz]
    end % props

    methods (Abstract)
        summary                                                            % print summary text
    end % meths

end % class
