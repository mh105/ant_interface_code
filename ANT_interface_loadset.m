function [ EEG ] = ANT_interface_loadset(filename, filepath, verbose, todouble) %#ok<INUSD>
%
% ANT INTERFACE CODES - LOADSET
%
% - used to load an EEGLAB format .set file containing the EEG structure
% with the data and other recording information.
%
% Last edit: Alex He 05/04/2024
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Inputs:
%           - filename:     file name of the .set file.
%
%           - filepath:     full path to the folder containing the .set
%                           file
%
%           - verbose:      whether print messages during processing.
%                           default: true
%
%           - todouble:     retained for backward compatibility. EEG.data
%                           is always returned as double precision.
%
% Output:
%           - EEG:          an EEGLAB structure containing all information
%                           from the .set file with double-precision data.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if nargin < 3
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

    ANTinterface_path = which('ANT_interface_loadset');
    temp = strsplit(ANTinterface_path, 'ANT_interface_loadset.m');

    % Add path to EEGLAB
    addpath(fullfile(temp{1}, 'eeglab14_1_2b'))
end

%% Load data
% Start EEGLab
eeglab nogui;

if verbose; tic; end
% Call pop_loadset.m function from EEGLAB to load .set file
EEG = pop_loadset(filename, filepath);
assert(isa(EEG.data, 'single'), ...
    'ANT_interface_loadset() requires EEG.data stored in single precision.');
EEG.data = double(EEG.data);
assert(isa(EEG.data, 'double'), ...
    'ANT_interface_loadset() must return EEG.data in double precision.');
if verbose
    disp(' ')
    disp('Total time taken in Loading the dataset...')
    disp(' ')
    toc
end

end
