function results = runnsdminibehavioralanalysis(filename,nsdexpfile,choicebuttons,previousexposure);

% function results = runnsdminibehavioralanalysis(filename,nsdexpfile,choicebuttons,previousexposure);
%
% <filename> is the .mat file saved from runnsdmini.m
% <nsdexpfile> is the experimental design .mat file that controls the nsdmini experiment
% <choicebuttons> (optional) is {C1 C2} such that C1 means novel and C2 means old.
%   Default: {'1' '2'}.
% <previousexposure> (optional) is a vector of 515 indices indicating any images that
%   should be considered previously seen (even for the first trial). For example,
%   you could pass in [3 155 515].
%
% Check timing and analyze the behavioral data.
% We report information to the command window and
% also return <results>.
%
% <results> is a struct with fields:
%   <presults> is the output of ptviewmoviecheck2.m with lots of information
%     on timing, buttons, and triggers.
%   <trialinfo> is N x 13 where N is the number of stimulus trials in the run.
%     column 1 is run number (1-10)
%     column 2 is stimulus trial number (1-103)
%     column 3 is the 73k ID of the presented image
%     column 4 is whether this is a case of special previous exposure (0/1)
%     column 5 is the trial start time (i.e. time that image comes on) as 
%                  a MATLAB serial date number. the units are days.
%     column 6 is 0 (novel) or 1 (old)
%     column 7 is 0 (incorrect) or 1 (correct)
%     column 8 is reaction time in milliseconds (time between trial start time
%                 and button-press time)
%     column 9 is whether this is a trial that involved more than one button press
%                 (0 = no, 1 = yes, NaN = no buttons pressed)
%     column 10 is number of stimulus trials in between current
%                  and most recent presentation. for cases of <previousexposure>,
%                  we act as if the previous showing was just prior to the first trial
%                  (i.e. the 0th trial).
%     column 11 is the total number of 1s ("novel") pressed during this trial
%     column 12 is the total number of 2s ("old") pressed during this trial
%     column 13 is the final button that we officially score (this will be either 1, 2, or NaN)
%     note that column 10 is NaN for the case of novel images.
%     note that columns 7-9 and 13 are NaN if no button was pressed for this trial
%   <responserate> is percent of stimulus trials with at least a button press
%   <finalscore> is percent of stimulus trials with a correct response
%   <medianrt> is the median reaction time in milliseconds
%
% Note that we detect user buttons from the time that the stimulus comes on
% until the time that the next trial starts (or would have started in the
% case of blank trials), except that we offset this by 250 ms.
%
% We process only the final button detected (if there is more than one), but
% specifically target the first instance of that one (if there is a series).
% 
% We look specifically for buttons named in <choicebuttons>.

% history:
% - 2026/05/31 - initial version

% input
if ~exist('choicebuttons','var') || isempty(choicebuttons)
  choicebuttons = {'1' '2'};
end
if ~exist('previousexposure','var') || isempty(previousexposure)
  previousexposure = [];
end
previousexposure = flatten(unique(previousexposure));

%% Simple frame and duration stuff

% load files
a1 = load(filename);
a2 = load(nsdexpfile);

% pre-process using ptviewmoviecheck2.m
presults = ptviewmoviecheck2(a1.timeframes,a1.timekeys,[],[],NaN);

%% Now analyze the behavior

% internal constants
windowoffset = 250;  % milliseconds of offset. decide to get buttons from [trialstart+offset,trialend+offset]

% calc
runnum = a1.setnum(2);
assert(runnum>=1 && runnum<=10);

% initialize results
clear results;

% process each trial
cnt = 1;  % this keeps track of the stimulus trial number
for p=1:size(a1.trialpattern,1)
  temp = find(a1.trialpattern(p,:));
  
  % if this is a stimulus trial
  if ~isempty(temp)
  
    % index of current stimulus trial (relative to 1030)
    ix = sum(a1.numstimperrun(1:runnum-1)) + cnt;
    
    % record basic information
    results.trialinfo(cnt,[1 2]) = [runnum cnt];
    
    % is this a special previous exposure?
    results.trialinfo(cnt,4) = ismember(a2.masterordering(ix),previousexposure);
    
    % is current image one of the previously shown ones? (0 means novel, 1 means old)
    results.trialinfo(cnt,6) = ismember(a2.masterordering(ix),[a2.masterordering(1:ix-1) previousexposure]);

    % record 73k ID
    results.trialinfo(cnt,3) = a2.special515ix(a2.masterordering(ix));
        
    % if current image is novel
    if results.trialinfo(cnt,6)==0

      results.trialinfo(cnt,[10]) = NaN;

    else

      % indices of previous stimulus trials (relative to 1030) [there will be exactly 1]
      ix2 = find(a2.masterordering(1:ix-1) == a2.masterordering(ix));
      if isempty(ix2)
        assert(results.trialinfo(cnt,4)==1);  % must be a special case
        ix2 = 0;  % act as the 0th trial
      end
      assert(length(ix2)==1);
      
      % how many stimulus trials separated from the most recent presentation?
      results.trialinfo(cnt,10) = ix - ix2 - 1;
      
    end
    
    % calc some times
    ondur = length(a1.onpattern);
    trialstart = presults.timeframes((p-1)*ondur + 1);          % time of first frame for this stimulus trial
    trialend =   presults.timeframes((p-1)*ondur + 1 + ondur);  % time of first frame for the next trial
    
    % find the buttons pressed during this time interval
    ok = find((presults.buttontimes > trialstart+windowoffset/1000) & (presults.buttontimes <= trialend+windowoffset/1000));

    % only want buttons that are one of the choice buttons
    good = logical(zeros(1,length(ok)));
    for qq=1:length(ok)
      good(qq) = ismember(presults.buttonpressed{ok(qq)},choicebuttons);
    end
    ok = ok(good);

    % if no buttons detected
    if isempty(ok)

      results.trialinfo(cnt,[7 8 9]) = NaN;
      results.trialinfo(cnt,[11 12]) = 0;
      results.trialinfo(cnt,[13]) = NaN;

    % otherwise, record RT (ms) and whether it was correct (0 or 1) in both versions
    else
      
      % if there is more than one unique button pressed, mark it as "change mind"
      if length(union(presults.buttonpressed(ok),[])) > 1
        results.trialinfo(cnt,9) = 1;
      else
        results.trialinfo(cnt,9) = 0;
      end
      
      % tally all the buttons pressed
      results.trialinfo(cnt,11) = sum(ismember(presults.buttonpressed(ok),choicebuttons{1}));
      results.trialinfo(cnt,12) = sum(ismember(presults.buttonpressed(ok),choicebuttons{2}));

      % handle the case of multiple buttons
      cnt0 = length(ok);
      while 1
        if cnt0-1 < 1
          break;  % if we are at the beginning, get out
        end
        if isequal(presults.buttonpressed{ok(cnt0-1)},presults.buttonpressed{ok(cnt0)})
          cnt0 = cnt0 - 1;  % if cnt0-1 is the same button, use that one!
        else
          break;  % if cnt0-1 is a different button, don't go any more into the past
        end
      end
      ok = ok(cnt0);  % score this button press (out of potentially many button presses)

      % calc
      timeofpress = presults.buttontimes(ok);  % time that key was pressed
      thekey = presults.buttonpressed{ok};     % the key that was pressed, e.g. '1'

      % RT (ms)
      results.trialinfo(cnt,8) = (timeofpress - trialstart) * 1000;
      
      % correctness (0 or 1)
      results.trialinfo(cnt,7) = ((results.trialinfo(cnt,6)==0) && (isequal(thekey,choicebuttons{1}))) || ...  % novel and '1' was pressed
                                 ((results.trialinfo(cnt,6)==1) && (isequal(thekey,choicebuttons{2})));        % old and '2' was pressed
      
      % record the button we actually scored
      if isequal(thekey,choicebuttons{1})
        results.trialinfo(cnt,13) = 1;
      else
        assert(isequal(thekey,choicebuttons{2}));
        results.trialinfo(cnt,13) = 2;
      end
      
    end
    
    % what is the absolute time that the trial started?
    results.trialinfo(cnt,5) = presults.matlabnowtime + trialstart/60/60/24;  % convert from seconds to days and then add in
    
    % increment the stimulus-trial counter
    cnt = cnt + 1;
  
  end
  
end

% calculate some summary metrics
results.responserate = sum(~isnan(results.trialinfo(:,8))) / size(results.trialinfo,1) * 100;  % percent stimulus trials with button press
results.finalscore =        nansum(results.trialinfo(:,7)) / size(results.trialinfo,1) * 100;  % percent correct
results.medianrt = nanmedian(results.trialinfo(:,8));

% include preprocessing results
results.presults = presults;

% report scores
fprintf('==============================================================\n');
fprintf(['Your response rate is %d%%.\n' ...
         'Your median RT is %d ms.\n' ...
         '\n' ...
         'OVERALL:\n' ...
         '  Out of %d novel stimulus trials, you had %d correct, %d incorrect, and %d no-response.\n' ...
         '  Out of %d old stimulus trials, you had %d correct, %d incorrect, and %d no-response.\n' ...
         '  Your overall percent correct is %d%%.\n' ...
         ], ...
        round(results.responserate), ...
        round(results.medianrt), ...
        ...
        sum(results.trialinfo(:,6)==0), ...
        sum(results.trialinfo(results.trialinfo(:,6)==0,7)==1), ...
        sum(results.trialinfo(results.trialinfo(:,6)==0,7)==0), ...
        sum(isnan(results.trialinfo(results.trialinfo(:,6)==0,7))), ...
        sum(results.trialinfo(:,6)==1), ...
        sum(results.trialinfo(results.trialinfo(:,6)==1,7)==1), ...
        sum(results.trialinfo(results.trialinfo(:,6)==1,7)==0), ...
        sum(isnan(results.trialinfo(results.trialinfo(:,6)==1,7))), ...
        round(results.finalscore));
fprintf('==============================================================\n');
