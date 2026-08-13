function [ EEG ] = ANT_interface_saveset(EEG_to_save, savefn, filepath, verbose)
%
% ANT INTERFACE CODES - SAVESET
%
% - saves the EEG structure as an EEGLAB .set format file for future use.
%
% Last edit: Alex He 05/05/2024
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Inputs:
%           - EEG_to_save:  EEG structurue containing recording data.
%
%           - savefn:       file name of the .set file to save. May or may
%                           not include the .set suffix.
%
%           - filepath:     full path to the folder to save the .set file
%
%           - verbose:      whether print messages during processing.
%                           default: true
%
% Output:
%           - EEG:          an EEGLAB structure containing all information
%                           of the recording in .cnt file.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if nargin < 4
    verbose = true;
end

% addpath to the appropriate folders
try
    SleepEEG_addpath(matlabroot);
    
catch
    % if using SleepEEG_addpath() fails, we will assume the current directory
    % has the ANT_interface_loadset.m or at least the folder containing it has
    % been added to path when calling this function. We will try to addpath to
    % EEGLAB directly.
    
    ANTinterface_path = which('ANT_interface_saveset');
    temp = strsplit(ANTinterface_path, 'ANT_interface_saveset.m');
    
    % Add path to EEGLAB
    addpath(fullfile(temp{1}, 'eeglab14_1_2b'))
end

% Start EEGLab
eeglab nogui;

%% Saving the EEG structure in the current workspace
if verbose
    tic
    disp(' ')
    disp('Saving EEG structure to .set file:')
    disp(' ')
    disp(fullfile(filepath, savefn))
end
% Call pop_saveset.m function from EEGLAB to save .set file
assert(isa(EEG_to_save.data, 'double'), ...
    'ANT_interface_saveset() requires EEG.data in double precision.');
EEG = pop_saveset(EEG_to_save, 'filename', savefn, 'filepath', filepath,...
    'savemode', 'onefile', 'version', '7.3');
assert(isa(EEG.data, 'double'), ...
    'ANT_interface_saveset() must preserve EEG.data in double precision.');

if verbose
    disp(' ')
    disp('Total time taken in Saving the dataset...')
    disp(' ')
    toc
end

end
