function runnsdmini

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FOR THE USER TO EDIT

% setup display resolution (see pton.m)
ptonparams = {[1920 1080 120 24],[],-2,0.0009};  % BOLDSCREEN (squaring CLUT because we need to simulate normal monitors)
ptonparams = {[],[],0};  % don't change resolution; use linear CLUT

% stimulus size stuff
% 7TAS + Nova1x32 + BOLDscreen:
ppd = 88.189484478585300;                 % pixels per deg
screenheight = 1080/ppd;                  % in degrees
screenverticalres = 1080;                 % in pixels

% eye-tracker
wanteyetracking = 0;                   % whether to try to hook up to the eyetracker
el_monitor_size    = [-349.2, 196.45, 349.2, -196.45]; % monitor size in millimeters (center to left, top, right, and bottom). Numbers come from [39.29 cm height, 69.84 cm width] --> [392.9 mm height, 698.4 mm width] * 0.5.
el_screen_distance = [1845 1845];  % distance in millimeters from eye to top and bottom edge of the monitor. Given the 183.5 cm viewing distance, this is calculated as:  sqrt(183.5^2+(32.5/2)^2)*10 and then rounded to nearest integer.    
point2point_distance_deg = 3.0;                                % desired target distance (in deg) from fixation 
point2point_distance_pix = round((point2point_distance_deg*ppd/2))*2; % desired target distance in pixels
cv_proportion_area = ([2,2].*point2point_distance_pix) ./ [1920,1080]; % proportion area for [x,y]-dimensions used by Eyelink to place automated calibration/validation target. 
pteyelinkonparams = { el_monitor_size ...
                      el_screen_distance ...
                      cv_proportion_area ...
                      point2point_distance_pix };

% other parameters
stimdiameter = 8.4;                    % desired stimulus side length in deg
triggerkey = '5';                      % key that starts the experiment
fixationsizedeg = 0.2;                 % dot diameter in deg
fixationsizeborder = 3;                % pixel-width for dot border
fixationinfo = {uint8([255 0 0]) 0.5};  % dot colors: red; 50% opacity
  %fixationinfo = {uint8([255 0 0; 0 0 0; 255 255 255]) 0.5};  % dot colors: red, black, white; 50% opacity
  %fixationinfo = {uint8(repmat([255; 255-lumstep; 255-2*lumstep],[1 3])) 1};
offset = [0 0];                        % [10 20] means move 10-px right, 20-px down
movieflip = [0 0];                     % whether to flip up-down, whether to flip left-right
tfunNOEYE = @() fprintf('STIMULUS START/STOP.\n');  % this is executed when the expt starts
tfunEYE =   @() cat(2,fprintf('STIMULUS START/STOP.\n'),Eyelink('Message','SYNCTIME'));
setupscript = 'showinstructionscreen(''runnsdmini_subjectinstructions.txt'',250,75,25,78)';  % inputs are (fileIn,txtOffset,instTextWrap,textsize,background)

% previous exposure to the 515 images?
previousexposure = [];
  %   %s30  = load('~/Dropbox/vcddata/stimuli/vcd/selected30.tsv');
  %   %s515 = load('~/Dropbox/vcddata/stimuli/vcd/special515.tsv');
  % s30  = load(['selected30.tsv']);
  % s515 = load(['special515.tsv']);
  % previousexposure = find(ismember(s515,s30))';

% advanced timing-related stuff (please see documentation in ptviewmovie.m)
fliplead = 10/1000;
ptime = 10/1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DON'T EDIT BELOW

% history:
% - 2026/10/08 - initial tweaked updated version committed to runnsd github repo!
% - 2026/05/31 - add behavioral analysis
% - 2026/05/30 - initial version.

%%%%%%%%%%%%%%%% historical purposes only:

meanchange = 3;                        % dot changes occur with this average interval (in seconds)
changeplusminus = 2;                   % plus or minus this amount (in seconds)

%%%%%%%%%%%%%%%% path stuff

stimulusdir = strrep(which('runnsdmini'),'runnsdmini.m','stimulusfiles');

%%%%%%%%%%%%%%%% need to get info from user

% ask the user what to run
if ~exist('subjnum','var') 
  subjnum = input('What is the subj id (0-999)? ')
end

% give some hints to the operator
tempfiles = matchfiles(sprintf('*_nsdmini_subj%03d_run*_exp*.mat',subjnum));
fprintf('\nIt appears you have completed the following runs already:\n');
tempfiles

% ask the user more stuff
expnum = 135;
runnum = input('What run number (1-10)? ')

%%%%%%%%%%%%%%%% continue

% there is no pre-loading, so just set these to []
images = [];
maskimages = [];

% calc
ts0 = gettimestring;
filename =    sprintf('%s_nsdmini_subj%03d_run%02d_exp%03d.mat',ts0,subjnum,runnum,expnum);
eyefilename = sprintf('eye_%s_nsdmini_subj%03d_run%02d_exp%03d.edf',ts0,subjnum,runnum,expnum);

% experiment-specific stuff
switch expnum
case 135

  assert(runnum>=1 && runnum<=10);

  setnum = [135 runnum];

  resofstim = 425;                                                          % original resolution of the stimuli
  dres = -((stimdiameter*ppd) / resofstim);                                 % scale factor to apply
  fixationsize = 2*round((fixationsizedeg * (screenverticalres/screenheight))/2);  % fixation diameter in pixels (EVEN)
  fprintf('dres (scale factor) = %.4f\n',dres);
  fprintf('fixationsize = %d pixels\n',fixationsize);
  
  fixationsize = [fixationsize fixationsizeborder];

  fps = 10;                                  % stimulus frames per second
  frameduration = ptonparams{1}(3) / fps;    % for how many monitor refreshes does each frame last?
  assert(isint(frameduration));

  grayval = uint8(127);                      % background color
  trialparams = [];
  soafun = @() round(meanchange*fps + changeplusminus*(2*(rand-.5))*fps);
  iscolor = 1;

  specialoverlay = [];

end

% deal with eyetracking
if wanteyetracking
  tfun = tfunEYE;
  eyefilename = eyefilename;
else
  tfun = tfunNOEYE;
  eyefilename = [];
end

% run experiment
showmulticlass(filename,offset,movieflip,frameduration,fixationinfo,fixationsize,tfun, ...
               ptonparams,soafun,0,images,setnum,[],grayval,iscolor,[],[], ...
               [],dres,triggerkey,[],trialparams,eyefilename,maskimages,specialoverlay,stimulusdir, ...
               [],[],setupscript,[],[],fliplead,ptime,pteyelinkonparams);

% analyze behavioral data
runnsdminibehavioralanalysis(filename,[stimulusdir '/nsdmini_expdesign.mat'],[],previousexposure);
