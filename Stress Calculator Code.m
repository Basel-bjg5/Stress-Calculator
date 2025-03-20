classdef group_2_stress_calculator < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        Theta_S_2              matlab.ui.control.NumericEditField
        EditField2_3Label_11   matlab.ui.control.Label
        Theta_S                matlab.ui.control.NumericEditField
        EditField2_3Label_10   matlab.ui.control.Label
        Max_Shear              matlab.ui.control.NumericEditField
        EditField2_3Label_9    matlab.ui.control.Label
        ShearLabel_2           matlab.ui.control.Label
        Theta_P2               matlab.ui.control.NumericEditField
        EditField2_3Label_8    matlab.ui.control.Label
        Theta_P1               matlab.ui.control.NumericEditField
        EditField2_3Label_7    matlab.ui.control.Label
        Sigma_2                matlab.ui.control.NumericEditField
        EditField2_3Label_6    matlab.ui.control.Label
        Sigma_1                matlab.ui.control.NumericEditField
        EditField2_3Label_5    matlab.ui.control.Label
        CalculateButton        matlab.ui.control.StateButton
        PrincipalsLabel        matlab.ui.control.Label
        Rot_Angle              matlab.ui.control.NumericEditField
        EditField2Label        matlab.ui.control.Label
        Shear_1                matlab.ui.control.NumericEditField
        EditField2_3Label_4    matlab.ui.control.Label
        Shear                  matlab.ui.control.NumericEditField
        ShearLabel             matlab.ui.control.Label
        Sigma_y1               matlab.ui.control.NumericEditField
        EditField2_3Label_3    matlab.ui.control.Label
        Sigma_y                matlab.ui.control.NumericEditField
        EditField2_2Label      matlab.ui.control.Label
        Sigma_x1               matlab.ui.control.NumericEditField
        EditField2_3Label_2    matlab.ui.control.Label
        Sigma_x                matlab.ui.control.NumericEditField
        EditField2_3Label      matlab.ui.control.Label
        RotationLabel          matlab.ui.control.Label
        OutputParametersLabel  matlab.ui.control.Label
        InputParametersLabel   matlab.ui.control.Label
        Label                  matlab.ui.control.Label
        Label_2                matlab.ui.control.Label
        UIAxes                 matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: CalculateButton
        function CalculateButtonValueChanged(app, event)
           
            % Store Inputs
            sigma_x = app.Sigma_x.Value;
            sigma_y = app.Sigma_y.Value;
            t_xy = app.Shear.Value;
            angle = app.Rot_Angle.Value;

            % Apply Equations

            angle = angle *pi/180; %from degree to Rad
            avg = (sigma_x + sigma_y)/2;
            diff_avg = (sigma_x - sigma_y)/2;
            sigma_x1 = avg + diff_avg*cos(2*angle) + t_xy*sin(2*angle);
            %sigma_y1 = avg - diff_avg*cos(2*angle) - t_xy*sin(2*angle);
            sigma_y1 = sigma_y + sigma_x - sigma_x1;
            t_x1y1 =  -1*diff_avg*sin(2*angle) + t_xy*cos(2*angle);
            theta_p1 = (1/2)*atan((t_xy)/(diff_avg));
            theta_p1 = 180*theta_p1/pi;%from Rad to degree
            theta_p2 = theta_p1 + 90;
            theta_s1  = theta_p1 + 45;
            theta_s2  = theta_s1 - 90;
            R = sqrt((diff_avg)^2 + (t_xy)^2);
            sigma_1 = avg + R;
            sigma_2 = avg - R;
            if (t_xy ==0 && sigma_y == sigma_x) 
                uialert(app.UIFigure, 'Wrong Inputs No valid angle solutions','success');
                return;
            end

            % Display Results
            app.Sigma_x1.Value  = sigma_x1;
            app.Sigma_y1.Value  = sigma_y1;
            app.Shear_1.Value   = t_x1y1;
            app.Sigma_1.Value   = sigma_1;
            app.Sigma_2.Value   = sigma_2;
            app.Theta_P1.Value  = theta_p1;
            app.Theta_P2.Value  = theta_p2;
            app.Max_Shear.Value = R;
            app.Theta_S.Value   = theta_s1;
            app.Theta_S_2.Value   = theta_s2;
            % Figure

            theta = linspace(0, 2*pi, 1000);
            x = R * cos(theta) + avg;
            y = R * sin(theta);
            set(app.UIAxes, 'YDir', 'reverse');
            

            % check specical figure Case

            if (sigma_x == sigma_y)
                X = sigma_x*ones(1,2);
                Y = linspace(-t_xy,t_xy,2);
            else
                X = linspace(sigma_x,sigma_y,2);
                Y = X*(t_xy/diff_avg) - (sigma_x * t_xy)/(diff_avg) + t_xy;
            end
            
            diff_avg_2 = (sigma_x1 - sigma_y1)/2;
            if (sigma_x1 == sigma_y1)
                D1 = sigma_x1*ones(1,2);
                D2 = linspace(-t_x1y1,t_x1y1,2);
            else
                D1 = linspace(sigma_x1,sigma_y1,2);
                D2 = D1*(t_x1y1/diff_avg_2) - (sigma_x1 * t_x1y1)/(diff_avg_2) + t_x1y1;
            end
            
            
            plot(x, y, 'b', 'Parent', app.UIAxes); % Mohr's circle
            hold(app.UIAxes, 'on');
            h2 = plot(X, Y, 'r', 'Parent', app.UIAxes); % Line
            h3 = plot(D1, D2, 'Color', [1, 0.5, 0], 'Parent', app.UIAxes); % Line
            legend(app.UIAxes , [h2,h3] , {'Perpendicular characteristic','Rotation characteristic'})
            hold(app.UIAxes, 'off');
            
    

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 728 593];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Mohr''s Circle')
            xlabel(app.UIAxes, 'σ_x1')
            ylabel(app.UIAxes, 'Shear')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [31 9 372 298];

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.BackgroundColor = [0.902 0.902 0.902];
            app.Label_2.Position = [455 39 224 534];
            app.Label_2.Text = '';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.BackgroundColor = [0.902 0.902 0.902];
            app.Label.Position = [66 358 186 215];
            app.Label.Text = '';

            % Create InputParametersLabel
            app.InputParametersLabel = uilabel(app.UIFigure);
            app.InputParametersLabel.FontSize = 14;
            app.InputParametersLabel.FontWeight = 'bold';
            app.InputParametersLabel.Position = [74 547 119 26];
            app.InputParametersLabel.Text = 'Input Parameters';

            % Create OutputParametersLabel
            app.OutputParametersLabel = uilabel(app.UIFigure);
            app.OutputParametersLabel.FontSize = 14;
            app.OutputParametersLabel.FontWeight = 'bold';
            app.OutputParametersLabel.Position = [486 547 161 26];
            app.OutputParametersLabel.Text = 'Output Parameters';

            % Create RotationLabel
            app.RotationLabel = uilabel(app.UIFigure);
            app.RotationLabel.FontWeight = 'bold';
            app.RotationLabel.Position = [460 510 149 26];
            app.RotationLabel.Text = 'Rotation';

            % Create EditField2_3Label
            app.EditField2_3Label = uilabel(app.UIFigure);
            app.EditField2_3Label.HorizontalAlignment = 'right';
            app.EditField2_3Label.Position = [70 499 58 22];
            app.EditField2_3Label.Text = 'Sigma_x  ';

            % Create Sigma_x
            app.Sigma_x = uieditfield(app.UIFigure, 'numeric');
            app.Sigma_x.HorizontalAlignment = 'left';
            app.Sigma_x.Position = [143 499 100 22];

            % Create EditField2_3Label_2
            app.EditField2_3Label_2 = uilabel(app.UIFigure);
            app.EditField2_3Label_2.HorizontalAlignment = 'right';
            app.EditField2_3Label_2.Position = [453 479 62 22];
            app.EditField2_3Label_2.Text = 'Sigma_x1 ';

            % Create Sigma_x1
            app.Sigma_x1 = uieditfield(app.UIFigure, 'numeric');
            app.Sigma_x1.Editable = 'off';
            app.Sigma_x1.HorizontalAlignment = 'left';
            app.Sigma_x1.Position = [530 479 130 22];

            % Create EditField2_2Label
            app.EditField2_2Label = uilabel(app.UIFigure);
            app.EditField2_2Label.HorizontalAlignment = 'right';
            app.EditField2_2Label.Position = [71 458 58 22];
            app.EditField2_2Label.Text = 'Sigma_y  ';

            % Create Sigma_y
            app.Sigma_y = uieditfield(app.UIFigure, 'numeric');
            app.Sigma_y.HorizontalAlignment = 'left';
            app.Sigma_y.Position = [144 458 100 22];

            % Create EditField2_3Label_3
            app.EditField2_3Label_3 = uilabel(app.UIFigure);
            app.EditField2_3Label_3.HorizontalAlignment = 'right';
            app.EditField2_3Label_3.Position = [455 438 58 22];
            app.EditField2_3Label_3.Text = 'Sigma_y1';

            % Create Sigma_y1
            app.Sigma_y1 = uieditfield(app.UIFigure, 'numeric');
            app.Sigma_y1.Editable = 'off';
            app.Sigma_y1.HorizontalAlignment = 'left';
            app.Sigma_y1.Position = [528 438 130 22];

            % Create ShearLabel
            app.ShearLabel = uilabel(app.UIFigure);
            app.ShearLabel.HorizontalAlignment = 'right';
            app.ShearLabel.Position = [72 417 57 22];
            app.ShearLabel.Text = 'Shear      ';

            % Create Shear
            app.Shear = uieditfield(app.UIFigure, 'numeric');
            app.Shear.HorizontalAlignment = 'left';
            app.Shear.Position = [144 417 100 22];

            % Create EditField2_3Label_4
            app.EditField2_3Label_4 = uilabel(app.UIFigure);
            app.EditField2_3Label_4.HorizontalAlignment = 'right';
            app.EditField2_3Label_4.Position = [454 397 60 22];
            app.EditField2_3Label_4.Text = 'Shear_1   ';

            % Create Shear_1
            app.Shear_1 = uieditfield(app.UIFigure, 'numeric');
            app.Shear_1.Editable = 'off';
            app.Shear_1.HorizontalAlignment = 'left';
            app.Shear_1.Position = [529 397 130 22];

            % Create EditField2Label
            app.EditField2Label = uilabel(app.UIFigure);
            app.EditField2Label.HorizontalAlignment = 'right';
            app.EditField2Label.Position = [69 373 61 22];
            app.EditField2Label.Text = 'Rot_Angle';

            % Create Rot_Angle
            app.Rot_Angle = uieditfield(app.UIFigure, 'numeric');
            app.Rot_Angle.HorizontalAlignment = 'left';
            app.Rot_Angle.Position = [145 373 100 22];

            % Create PrincipalsLabel
            app.PrincipalsLabel = uilabel(app.UIFigure);
            app.PrincipalsLabel.FontWeight = 'bold';
            app.PrincipalsLabel.Position = [461 354 149 26];
            app.PrincipalsLabel.Text = 'Principals';

            % Create CalculateButton
            app.CalculateButton = uibutton(app.UIFigure, 'state');
            app.CalculateButton.ValueChangedFcn = createCallbackFcn(app, @CalculateButtonValueChanged, true);
            app.CalculateButton.Text = 'Calculate';
            app.CalculateButton.Position = [118 332 100 22];

            % Create EditField2_3Label_5
            app.EditField2_3Label_5 = uilabel(app.UIFigure);
            app.EditField2_3Label_5.HorizontalAlignment = 'right';
            app.EditField2_3Label_5.Position = [459 315 59 22];
            app.EditField2_3Label_5.Text = 'Sigma_1  ';

            % Create Sigma_1
            app.Sigma_1 = uieditfield(app.UIFigure, 'numeric');
            app.Sigma_1.Editable = 'off';
            app.Sigma_1.HorizontalAlignment = 'left';
            app.Sigma_1.Position = [533 315 130 22];

            % Create EditField2_3Label_6
            app.EditField2_3Label_6 = uilabel(app.UIFigure);
            app.EditField2_3Label_6.HorizontalAlignment = 'right';
            app.EditField2_3Label_6.Position = [460 280 59 22];
            app.EditField2_3Label_6.Text = 'Sigma_2  ';

            % Create Sigma_2
            app.Sigma_2 = uieditfield(app.UIFigure, 'numeric');
            app.Sigma_2.Editable = 'off';
            app.Sigma_2.HorizontalAlignment = 'left';
            app.Sigma_2.Position = [534 280 129 22];

            % Create EditField2_3Label_7
            app.EditField2_3Label_7 = uilabel(app.UIFigure);
            app.EditField2_3Label_7.HorizontalAlignment = 'right';
            app.EditField2_3Label_7.Position = [455 240 64 22];
            app.EditField2_3Label_7.Text = 'Theta_P_1';

            % Create Theta_P1
            app.Theta_P1 = uieditfield(app.UIFigure, 'numeric');
            app.Theta_P1.Editable = 'off';
            app.Theta_P1.HorizontalAlignment = 'left';
            app.Theta_P1.Position = [534 240 129 22];

            % Create EditField2_3Label_8
            app.EditField2_3Label_8 = uilabel(app.UIFigure);
            app.EditField2_3Label_8.HorizontalAlignment = 'right';
            app.EditField2_3Label_8.Position = [455 205 64 22];
            app.EditField2_3Label_8.Text = 'Theta_P_2';

            % Create Theta_P2
            app.Theta_P2 = uieditfield(app.UIFigure, 'numeric');
            app.Theta_P2.Editable = 'off';
            app.Theta_P2.HorizontalAlignment = 'left';
            app.Theta_P2.Position = [534 205 129 22];

            % Create ShearLabel_2
            app.ShearLabel_2 = uilabel(app.UIFigure);
            app.ShearLabel_2.FontWeight = 'bold';
            app.ShearLabel_2.Position = [461 160 149 26];
            app.ShearLabel_2.Text = 'Shear';

            % Create EditField2_3Label_9
            app.EditField2_3Label_9 = uilabel(app.UIFigure);
            app.EditField2_3Label_9.HorizontalAlignment = 'right';
            app.EditField2_3Label_9.Position = [461 126 66 22];
            app.EditField2_3Label_9.Text = 'Max_Shear';

            % Create Max_Shear
            app.Max_Shear = uieditfield(app.UIFigure, 'numeric');
            app.Max_Shear.Editable = 'off';
            app.Max_Shear.HorizontalAlignment = 'left';
            app.Max_Shear.Position = [542 126 130 22];

            % Create EditField2_3Label_10
            app.EditField2_3Label_10 = uilabel(app.UIFigure);
            app.EditField2_3Label_10.HorizontalAlignment = 'right';
            app.EditField2_3Label_10.Position = [463 88 64 22];
            app.EditField2_3Label_10.Text = 'Theta_S1  ';

            % Create Theta_S
            app.Theta_S = uieditfield(app.UIFigure, 'numeric');
            app.Theta_S.Editable = 'off';
            app.Theta_S.HorizontalAlignment = 'left';
            app.Theta_S.Position = [542 88 130 22];

            % Create EditField2_3Label_11
            app.EditField2_3Label_11 = uilabel(app.UIFigure);
            app.EditField2_3Label_11.HorizontalAlignment = 'right';
            app.EditField2_3Label_11.Position = [464 51 64 22];
            app.EditField2_3Label_11.Text = 'Theta_S2  ';

            % Create Theta_S_2
            app.Theta_S_2 = uieditfield(app.UIFigure, 'numeric');
            app.Theta_S_2.Editable = 'off';
            app.Theta_S_2.HorizontalAlignment = 'left';
            app.Theta_S_2.Position = [543 51 130 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = group_2_stress_calculator

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
