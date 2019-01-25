function [] = gen_GT(path)
% Input: 
%   -path : training image file path
%   **PROGRAM WAS DESIGNED FOR IMAGE SIZE 1024x768 ONLY!*****
% Author:  Ravit Pichayavet
% Date:  26/01/2019

D = dir(strcat(path,'/*.jpg'));  % or jpeg or whatever.
S.dir = path;
S.NAM = {D(:).name};  % Store the name of all items returned in D.
% Window size
S.fh = figure('units','pixels',...
              'position',[450 450 400 200],...
              'menubar','none',...
              'name','Verify Password.',...
              'resize','off',...
              'numbertitle','off',...
              'name','Generate Ground Thruth');
% Background color 
S.ls = uicontrol('style','list',...
                 'units','pix',...
                 'position',[10 60 380 120],...
                 'backgroundcolor','w',...
                 'string',S.NAM,...
                 'HorizontalAlign','left');
%  Push Button
S.pb = uicontrol('style','push',...
                 'units','pix',...
                 'position',[10 10 380 40],...
                 'backgroundcolor','w',...
                 'HorizontalAlign','left',...
                 'string','Load Image',...
                 'fontsize',14,'fontweight','bold',...
                 'callback',{@pb_call1,S});         
            
function [] = pb_call1(varargin)
% Callback for pushbutton.
% disp(varargin{1});
% disp(varargin{2});
% disp(varargin{3});
S = varargin{3};
% disp(S)
% disp(S.dir)
L = get(S.ls,{'string';'value'});  % L{1} is all of the file name, L{2} the selected index
% try
file_name = L{1}{L{2}};  % Give it a name for the base workspace.
filepath = strcat(S.dir,'/',file_name);
E.IMG = imread(filepath); % Read the image.
fprintf('\t\t%s %s %s\n','Load',file_name,' Success!');
E.fh = figure('units','pixels',...
          'position',[560 528 5600 420],...
          'menubar','none',...
          'name',file_name,...              
          'resize','off',...
          'numbertitle','off');% Create a new GUI.
     
%% SHOWING POSITION & SET IMAGE AS BG

set(gcf, 'Units', 'Normalized', 'OuterPosition', [20, 10, 1, 0.96]);
%set(E.ax,'unit','pix','position',[40 40 480 340]);
% axis([0 1024 0 768])

E.ax = gca;
hold off;
% E.IH = imshow(E.IMG,'Parent',E.ax, 'InitialMagnification', 'fit');
E.IH = image(E.IMG,'Parent',E.ax, 'HitTest', 'off');
% hold on;
E.ax.HitTest = 'on';
E.ax.XLim = [0 1024];
E.ax.YLim = [0 768];
% E.ax = axes('xlim',[0 1024],'ylim',[0 768]);
% E.IH = imshow(E.IMG,'Parent',E.ax);
% hold on;

% E.ax = gca;
% Fill the structure with data.
E.XLM = get(E.ax,'xlim');
E.YLM = get(E.ax,'ylim');
E.AXP = get(E.ax,'pos');
E.DFX = diff(E.XLM);
E.DFY = diff(E.YLM);
E.ln = [];
E.location = [];
E.ind = 0;
E.tx(1) = uicontrol('style','tex',...
                    'unit','pix',...
                    'posit',[50+750 700 250 20],...
                    'backg',get(E.fh,'color'),...
                    'fontsize',14,'fontweight','bold',... 
                    'string','Current Pointer Location:');
% This textbox will display the current position of the mouse.
E.tx(2) = uicontrol('style','tex',...
                    'unit','pix',...
                    'position',[310+720 700 120 20],...
                    'backg',get(E.fh,'color'),...
                    'fontsize',14,'fontweight','bold' );
E.ed = uicontrol('style','edit',...
              'units','pixels',...
              'position',[250 700 150 40],...
              'string',get(E.fh,'name'));
E.pb2 = uicontrol('style','push',...
                 'units','pix',...
                 'position',[100 700 150 40],...
                 'backgroundcolor','w',...
                 'HorizontalAlign','left',...
                 'string','Save as .mat file to',...
                 'fontsize',14,'fontweight','bold',...
                 'callback',{@pb_call2,E});
E.tx(3) = uicontrol('style','tex',...
                    'unit','pix',...
                    'posit',[50+400 700 350 20],...
                    'backg',get(E.fh,'color'),...
                    'fontsize',14,'fontweight','bold',... 
                    'string','Click to add points. Right click for options.');
                
%% PLOTTING CLICKED POSITION AND SAVING THE POINT
E.cm = uicontextmenu;
E.um(1) = uimenu(E.cm,...
             'label','Undo',...
             'Callback', {@um1_call,E});
E.um(2) = uimenu(E.cm,...
             'label','Delete All Points',...
             'Callback', {@um2_call,E});
set(E.ax,'buttondownfcn',{@ax_bdfcn,E},'uicontextmenu',E.cm)
set(E.fh,'windowbuttonmotionfcn',{@fh_wbmfcn,E}) % Set the motion detector.

function [] = pb_call2(varargin)
S = varargin{3};
image_info{1}.location =S.location;
image_info{1}.number = length(S.location)
file_name = get(S.ed,'string');
file_name = file_name(1:end-4);
full_path = strcat(file_name,'.mat');
save(full_path,'image_info')


function [] = fh_wbmfcn(varargin)
% WindowButtonMotionFcn for the figure.
S = varargin{3};  % Get the structure.
F = get(S.fh,'currentpoint');  % The current point w.r.t the figure.
% Figure out of the current point is over the axes or not -> logicals.
tf1 = S.AXP(1) <= F(1) && F(1) <= S.AXP(1) + S.AXP(3);
tf2 = S.AXP(2) <= F(2) && F(2) <= S.AXP(2) + S.AXP(4);
if tf1 && tf2
    % Calculate the current point w.r.t. the axes.
    Cx =  S.XLM(1) + (F(1)-S.AXP(1)).*(S.DFX/S.AXP(3));
    Cy =  S.YLM(1) + (F(2)-S.AXP(2)).*(S.DFY/S.AXP(4));
    set(S.tx(2),'str',num2str([Cx,Cy],2))
end      

function [] = ax_bdfcn(varargin)
% Serves as the buttondownfcn for the axes.
S = varargin{3};  % Get the structure.
seltype = get(S.fh,'selectiontype'); % Right-or-left click?
L = length(S.ln);
S.ind = L+1;
if strmatch(seltype,'normal')
    p = get(S.ax, 'currentpoint'); % Get the position of the mouse.
    S.ln(L+1) = line(p(1),p(3),'Marker','+','MarkerSize',10,'MarkerEdgeColor','r','LineWidth',2)  % Make our plot.
%     disp(p(1));disp(p(3));
    S.location = [S.location;[p(1),p(3)]];
    disp(length(S.location));
    disp(S.location);
    set(S.ln(L+1),'uicontextmenu',S.cm)  % So user can click a point too.
    % Update structure.
    set(S.pb2,'callback', {@pb_call2,S});
    set(S.ax,'ButtonDownFcn',{@ax_bdfcn,S}); 
    set(S.um(:),{'callback'},{{@um1_call,S};{@um2_call,S}});
end

function [] = um1_call(varargin)
% Callback for uimenu to undo last step.
try
    S = varargin{3};  % Get the structure.
    delete(S.ln(length(S.ln)));
    S.ln(end) = [];
    S.location(end,:) =[];
    disp(length(S.location));
    disp(S.location);
    % S.ln(find(S.ln( = 
    % delete(S.ln(:));  % Delete all the lines.
    set(S.pb2,'callback', {@pb_call2,S});
    set(S.um(:),{'callback'},{{@um1_call,S};{@um2_call,S}});
    set(S.ax,'ButtonDownFcn',{@ax_bdfcn,S});
catch
    disp('All points have been deleted!');
end

function [] = um2_call(varargin)
% Callback for uimenu to delete all points
% try
    S = varargin{3};  % Get the structure.
    delete(S.ln(:));  % Delete all the lines.
    S.location(:) = [];
    S.ln = [];  % And reset the structure.
    disp(length(S.location));
    disp(S.location);
    set(S.pb2,'callback', {@pb_call2,S});
    set(S.ax,'ButtonDownFcn',{@ax_bdfcn,S})
% catch
%     disp('All points have been deleted!');
% end    



