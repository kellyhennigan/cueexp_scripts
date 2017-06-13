function [stims,stimFiles]=getCueExpStims(task)
% -------------------------------------------------------------------------
% usage: function to return the stim names of interest for a given task
% (either cue,mid, or midi) and to return the corresponding names of the
% stim onset files.

% INPUT:
%   task - must be either 'cue', 'mid', or 'midi'
%

% OUTPUT:
%   stims - cell array of stim names
%   stimFiles - cell array of stim onset file names corresponding to stims.
%   Note that the onset times denote the onset time of the start of each
%   trial for that stim type, not necessarily the onset of the stim itself.
%   This is useful for plotting VOI time courses of trials.

% author: Kelly, kelhennigan@gmail.com, 05-Apr-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch task
    
    case 'cue'  % cue fmri task
        
        stims =  {'alcohol',...
            'drugs',...
            'food',...
            'neutral',...
            'strong_dontwant',...
            'somewhat_dontwant',...
            'somewhat_want',...
            'strong_want'};
        
        
        stimFiles =  {'alcohol_cue_cue.1D',...
            'drugs_cue_cue.1D',...
            'food_cue_cue.1D',...
            'neutral_cue_cue.1D',...
            'strongdontwant_cue_cue.1D',...
            'somewhatdontwant_cue_cue.1D',...
            'somewhatwant_cue_cue.1D',...
            'strongwant_cue_cue.1D'};
        
    case 'mid'
        
        stims =  {'loss0',...
            'loss1',...
            'loss5',...
            'gain0',...
            'gain1',...
            'gain5',...
            'losswin',...
            'lossmiss',...
            'gainwin',...
            'gainmiss'};
        
        
        stimFiles =  {'loss0_trial_mid.1D',...
            'loss1_trial_mid.1D',...
            'loss5_trial_mid.1D',...
            'gain0_trial_mid.1D',...
            'gain1_trial_mid.1D',...
            'gain5_trial_mid.1D',...
            'losswin_trial_mid.1D',...
            'lossmiss_trial_mid.1D',...
            'gainwin_trial_mid.1D',...
            'gainmiss_trial_mid.1D'};
        
    case 'midi'
        
%         stims =  {'gain0GO',...  % each trial type
%             'gain0NOGO',...
%             'loss0GO',...
%             'loss0NOGO',...
%             'gain5GO',...
%             'gain5NOGO',...
%             'loss5GO',...
%             'loss5NOGO',...    
%             'gain0GOwin',...    $ each trial time if trial won
%             'gain0NOGOwin',...
%             'loss0GOwin',...
%             'loss0NOGOwin',...
%             'gain5GOwin',...
%             'gain5NOGOwin',...
%             'loss5GOwin',...
%             'loss5NOGOwin',...
%             'gain0GOmiss',...   % eech trial type if trial lost 
%             'gain0NOGOmiss',...
%             'loss0GOmiss',...
%             'loss0NOGOmiss',...
%             'gain5GOmiss',...
%             'gain5NOGOmiss',...
%             'loss5GOmiss',...
%             'loss5NOGOmiss'};

  stims =  {'gain0GO',...  % each trial type
            'gain0NOGO',...
            'loss0GO',...
            'loss0NOGO',...
            'gain5GO',...
            'gain5NOGO',...
            'loss5GO',...
            'loss5NOGO',...    
            'gain0GOwin',...    $ each trial time if trial won
            'gain0NOGOwin',...
            'loss0GOwin',...
            'loss0NOGOwin',...
            'gain5GOwin',...
            'gain5NOGOwin',...
            'loss5GOwin',...
            'loss5NOGOwin'};
        
        
%         stimFiles =  {'gain0GO_trial_midi.1D',...
%             'gain0NOGO_trial_midi.1D',...
%             'loss0GO_trial_midi.1D',...
%             'loss0NOGO_trial_midi.1D',...
%             'gain5GO_trial_midi.1D',...
%             'gain5NOGO_trial_midi.1D',...
%             'loss5GO_trial_midi.1D',...
%             'loss5NOGO_trial_midi.1D',...
%             'gain0GOwin_trial_midi.1D',...
%             'gain0NOGOwin_trial_midi.1D',...
%             'loss0GOwin_trial_midi.1D',...
%             'loss0NOGOwin_trial_midi.1D',...
%             'gain5GOwin_trial_midi.1D',...
%             'gain5NOGOwin_trial_midi.1D',...
%             'loss5GOwin_trial_midi.1D',...
%             'loss5NOGOwin_trial_midi.1D',...
%             'gain0GOmiss_trial_midi.1D',...
%             'gain0NOGOmiss_trial_midi.1D',...
%             'loss0GOmiss_trial_midi.1D',...
%             'loss0NOGOmiss_trial_midi.1D',...
%             'gain5GOmiss_trial_midi.1D',...
%             'gain5NOGOmiss_trial_midi.1D',...
%             'loss5GOmiss_trial_midi.1D',...
%             'loss5NOGOmiss_trial_midi.1D'};
%         
          stimFiles =  {'gain0GO_trial_midi.1D',...
            'gain0NOGO_trial_midi.1D',...
            'loss0GO_trial_midi.1D',...
            'loss0NOGO_trial_midi.1D',...
            'gain5GO_trial_midi.1D',...
            'gain5NOGO_trial_midi.1D',...
            'loss5GO_trial_midi.1D',...
            'loss5NOGO_trial_midi.1D',...
            'gain0GOwin_trial_midi.1D',...
            'gain0NOGOwin_trial_midi.1D',...
            'loss0GOwin_trial_midi.1D',...
            'loss0NOGOwin_trial_midi.1D',...
            'gain5GOwin_trial_midi.1D',...
            'gain5NOGOwin_trial_midi.1D',...
            'loss5GOwin_trial_midi.1D',...
            'loss5NOGOwin_trial_midi.1D'};
        
end
