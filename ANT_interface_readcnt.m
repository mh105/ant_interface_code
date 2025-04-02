function [ EEG ] = ANT_interface_readcnt(filename, filepath, dsrate, verbose)
%
% ANT INTERFACE CODES - READCNT
%
% - this function is used to read a .cnt file exported from the ANT eego
% mylab system (2019). It expects a .cnt file, a .evt file, and a .seg file
% (if the recording was broken into multiple segments) with the same naming
% before the file extension.
%
% Last edit: Alex He 03/05/2025
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Inputs:
%           - filename:     file name of the .cnt file, the .evt and .seg
%                           files must have the same naming before the
%                           extension.
%
%           - filepath:     full path to the folder containing the .cnt
%                           file (and .evt, .seg files).
%
%           - dsrate:       whether to downsample and desired sampling
%                           rate. This is useful when the recording is
%                           very long such that we can't keep a large data
%                           structure in the original sampling rate in
%                           cache memory.
%                           default: [false, 0]
%
%           - verbose:      whether print messages during processing.
%                           default: true
%
% Output:
%           - EEG:          an EEGLAB structure containing all information
%                           of the recording in the .cnt file.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% set default values of flag arguments
if nargin < 3
    dsrate = [false, 0];
    verbose = true;
elseif nargin < 4
    verbose = true;
end

%% Addpath to required toolbox folders
% Note: this section expects the EEGLAB folders to exist in the same
% directory as the ANT_interface_readcnt.m function. If not, you would have
% to manually addpath to the folder containing these toolbox folders, or
% you can modify the directories to point to your desired locations.

try
    % Let's first attempt to use the butter function SleepEEG_addpath(). You
    % should be able to call it if you are using ANT_interface_readcnt() from
    % any of the SleepEEG_ functions.
    SleepEEG_addpath(matlabroot);
catch
    % if using SleepEEG_addpath() fails, we will assume the current directory
    % has the ANT_interface_readcnt.m or at least the folder containing it has
    % been added to path when calling this function. We will try to addpath to
    % ANT importer and EEGLAB directly.

    ANTinterface_path = which('ANT_interface_readcnt');
    temp = strsplit(ANTinterface_path, 'ANT_interface_readcnt.m');

    % Add path to ANT importer
    addpath(fullfile(temp{1}, 'ANTeepimport1.13'))

    % Add path to EEGLAB
    addpath(fullfile(temp{1}, 'eeglab14_1_2b'))

    % Add path to EEGLAB firfilt plugin for pop_resample()
    addpath(fullfile(temp{1}, 'eeglab14_1_2b/plugins/firfilt1.6.2'))
end

%% Start EEGLab
eeglab nogui;

%% Construct data filename
datafn = fullfile(filepath, filename);

%% Report EEG record length
if verbose
    disp(' ')
    if dsrate(1)
        disp('Loading and Downsampling...')
    else
        disp('Loading data file...')
    end
    disp(' ')

    if ~isfile(datafn) % if .cnt file not on disk report error
        error('Cannot locate the .cnt file. Please check the path and filename :\n%s.',datafn)
    else
        disp('Loading .cnt file from:')
        disp(datafn)
    end
end

cnt_info = eepv4_read_info(datafn); % this function is case-insensitive!
tot_sample_point = cnt_info.sample_count;
record_time = tot_sample_point/cnt_info.sample_rate/60;

if verbose
    disp(['Total recording duration = ' num2str(record_time) ' minutes = ', num2str(record_time/60) ' hours.'])
    disp(['Total sample points = ' num2str(cnt_info.sample_count) '.'])
    disp(' ')
end

%% Load data in pieces
% construct 30-min segment sample points for looping
sample_point = 0:cnt_info.sample_rate*60*30:cnt_info.sample_count;
sample_point = [sample_point cnt_info.sample_count]; % add in the last sample point
if verbose
    if length(sample_point) > 2
        disp(['A total of ' num2str(length(sample_point)-1) ' segments of 30min'])
    else
        disp(['A total of ' num2str(length(sample_point)-1) ' segment of ' num2str(record_time) 'min'])
    end
end

% load each segment sequentially and save each segment into a cell store
EEG_store = cell(1, length(sample_point)-1);

if verbose; tic; end
for i = 1:length(sample_point)-1
    % load in one segment of data
    if i == 1
        sample1 = 1;
    else
        sample1 = sample_point(i)+1;
    end
    sample2 = sample_point(i+1);
    if verbose
        disp(' ')
        disp(['Loading the ' num2str(i) 'th segment...'])
        disp(['sample1: ', num2str(sample1)])
        disp(['sample2: ', num2str(sample2)])
    end

    % use pop_loadeep_v4.m function to load in the segment
    EEG = pop_loadeep_v4(datafn, 'sample1', sample1, 'sample2', sample2);

    % test whether export montage and filtering was applied
    if i == 1 % we only need to check the first segment to raise the error
        [pxx,f] = pwelch(EEG.data(1,:),[],[],[],EEG.srate);
        % if filtering was applied, the high frequency content will be less
        % than -100dB! This likely implies that post-hoc montage and
        % filtering was applied when exporting the raw data from eego
        % software into .cnt and .evt files. Please re-export!
        pxx_db_high = pow2db(pxx(f>=(EEG.srate/2 * 0.8))); % check in the 400-500Hz range if srate is 1000Hz
        mean_db_high = mean(pxx_db_high(isfinite(pxx_db_high)));
        assert(mean_db_high >= -100, 'The high frequency power in LM is abnormally low. Do not apply montages and filtering when exporting raw data in eego!')
    end

    if dsrate(1) % if downsampling flag is true
        % For using pop_resample function: trials number is updated to be 1
        if EEG.trials == 0
            EEG.trials = 1;
        end

        % downsample to desired sampling rate in Hz as specified by dsrate(2)
        % pop_resample function
        % Inputs:
        %   INEEG      - input dataset
        %   freq       - frequency to resample (Hz)
        %
        % Optional inputs:
        %   fc         - anti-aliasing filter cutoff (pi rad / sample)
        %                {default 0.9}
        %   df         - anti-aliasing filter transition band width (pi rad /
        %                sample) {default 0.2}
        if verbose; disp(' '); disp('Downsampling...'); end
        EEG = pop_resample(EEG, dsrate(2), 0.9, 0.1);

        % When EEG.event is resampled, there could be non-integer latency
        % values. We write a for loop to convert them to next larger
        % integer using the ceil() function.
        for j = 1:length(EEG.event)
            EEG.event(j).latency = ceil(EEG.event(j).latency);
        end

    else
        if verbose
            disp(' ')
            disp('Downsampling is turned off. Original sampling rate will be retained.')
        end
        EEG = eeg_checkset(EEG, 'eventconsistency');
    end

    % save the downsampled data to a temporary cell
    EEG_store{i} = EEG;

    % clearvars to free up memory
    clearvars EEG
end
if verbose
    disp(' ')
    if dsrate(1)
        disp('Total time taken in Loading and Downsampling...')
    else
        disp('Total time taken in Loading...')
    end
    disp(' ')
    toc
end

%% Cascade downsampled data
if verbose
    disp(' ')
    if dsrate(1)
        disp('Concatenating downsampled data...')
    else
        disp('Concatenating data in original sampling rate...')
    end
    disp(' ')
end

if verbose; tic; end
% Pick up the first EEG structure
EEG = EEG_store{1};
if verbose; disp('Concatenating the 1st segment...'); end
% Loop through the rest EEG structures
for i = 2:length(EEG_store) % starts from 2nd index
    % Confirm that the sampling rates are identical and they are from the same original file
    assert(EEG.srate == EEG_store{i}.srate, 'Different sampling rate, please check!')
    assert(strcmp(EEG.comments, EEG_store{i}.comments), 'Different original file!')
    assert(size(EEG.data, 1) == size(EEG_store{i}.data, 1), 'Different numbers of channels!')

    % Use EEGLAB function pop_mergeset() to merge the two structures
    EEG = pop_mergeset(EEG, EEG_store{i});

    % Check if impedance measures should be incorporated
    if ~isempty(EEG_store{i}.endimp)
        EEG.endimp = EEG_store{i}.endimp;
    end
    if ~isempty(EEG_store{i}.initimp)
        EEG.initimp = EEG_store.initimp;
    end

    if verbose; disp(['Concatenating the ' num2str(i) 'th segment...']); end
end
if verbose
    disp('Total time taken in Concatenating Data...')
    disp(' ')
    toc
    disp(' ')
end

% Clear EEG_store to free up memory
clearvars EEG_store

%% Set montage
% This function does two things:
%   - adds an empty reference channel back
%   - fills in the channel location info from a template
EEG = ANT_interface_setmontage(EEG, 'auto');

end


function [ EEG ] = ANT_interface_setmontage(EEG, montage)
%
% ANT INTERFACE CODES - SETMONTAGE
%
% - a new function to automatically detect which cap montage was used for
% the recording and to **load** the correct template channel locations. An
% empty reference channel is also added to the data to preserve rank in
% subsequent processing such as re-referencing and for forward modeling.
%
% This function now replaces sections calling ANT_interface_eego2asa(),
% loading the Duke template channel location (chanlocs), and updating the
% EEG structure .ref and .refscheme fields in ANT_interface_readcnt().
%
% A key change is that the recording channel order is kept intact. Instead,
% corresponding coordinates are grabbed from the template chanlocs. This is
% so that the exported data can be handled similarly either as .cnt file
% and read with ANT_interface_readcnt(), or as BrainVision files and read
% directly into MNE-Python.
%
% Last edit: Alex He 04/01/2025
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Inputs:
%           - EEG:          an EEG structure with EEG.data in the order of
%                           eego mylab EEG system used to collect the data.
%           - montage:      a string specifying which montage to use,
%                           default to 'auto' that automatically detects
%                           the montage used.
%
% Output:
%           - EEG:          an EEG structure with EEG.data in the same
%                           order as the input structure, with an empty
%                           reference channel added to the end, and with
%                           correct channel location info filled in the
%                           .chanlocs field.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Make sure the correct number of channels is read from the .cnt file
assert(EEG.nbchan == length(EEG.chanlocs), 'Inconsistent number of channels read from .cnt file.')

if nargin < 2
    montage = 'auto';
end

%% Automatically detect the montage used
if strcmp(montage, 'auto')
    % Extract the current channel labels
    labels = {EEG.chanlocs.labels};

    % Auto-detect among waveguard montages

    % 128-channel montages
    if strcmp(labels{1}, 'Lm') && ...
            strcmp(labels{85}, 'VEOGL') && ...
            ~any(cellfun(@(x) strcmp(x, 'Z3'), labels)) && ...
            ~any(cellfun(@(x) strcmp(x, 'LL14'), labels))
        montage = 'gelDuke-Z3';

    elseif strcmp(labels{1}, 'Z2') && ...
            strcmp(labels{66}, 'VEOGL') && ...
            ~any(cellfun(@(x) strcmp(x, 'Z3'), labels)) && ...
            ~any(cellfun(@(x) strcmp(x, 'LL14'), labels))
        montage = 'salineDuke-Z3';

    elseif strcmp(labels{1}, 'Z2') && ...
            strcmp(labels{66}, 'LL14') && ...
            ~any(cellfun(@(x) strcmp(x, 'Z7'), labels)) && ...
            ~any(cellfun(@(x) strcmp(x, 'VEOGL'), labels))
        montage = 'salineNet-Z7';

    % 64-channel montages
    elseif strcmp(labels{1}, 'VEOGL') && ...
            strcmp(labels{2}, '1Z') && ...
            ~any(cellfun(@(x) strcmp(x, '0Z'), labels)) && ...
            ~any(cellfun(@(x) strcmp(x, '11L'), labels))
        montage = 'gelDuke-0Z';

    elseif strcmp(labels{1}, '1Z') && ...
            strcmp(labels{30}, '11R') && ...
            ~any(cellfun(@(x) strcmp(x, '5Z'), labels)) && ...
            ~any(cellfun(@(x) strcmp(x, 'VEOGL'), labels))
        montage = 'salineNet-5Z';

    else
        error('Could not detect a compatible montage. Please manually check!')

    end
end

%% Add the reference channel back to the data
% Set the number of expected electrodes based on montage - actualy numbers
% may exceed this value if additional auxiliary electrodes are used
switch montage
    case {'gelDuke-Z3', 'salineDuke-Z3', 'salineNet-Z7'}
        n_referential_leads = 129;
    case {'gelDuke-0Z', 'salineNet-5Z'}
        n_referential_leads = 65;
end

% Move the extra channels (such as bipolar) if there is any
if EEG.nbchan >= n_referential_leads
    EEG.data(n_referential_leads+1:EEG.nbchan+1, :) = EEG.data(n_referential_leads:end, :);
    EEG.chanlocs(n_referential_leads+1:EEG.nbchan+1) = EEG.chanlocs(n_referential_leads:end);
    if ~isempty(EEG.initimp)
        EEG.initimp(n_referential_leads+1:EEG.nbchan+1) = EEG.initimp(n_referential_leads:end);
    end
    if ~isempty(EEG.endimp)
        EEG.endimp(n_referential_leads+1:EEG.nbchan+1) = EEG.endimp(n_referential_leads:end);
    end
end

% Insert a reference channel as zero recording
EEG.data(n_referential_leads, :) = zeros(1, EEG.pnts);

% Update the reference field
EEG.ref = 'see refscheme';

% Add the reference channel to chanlocs
switch montage
    case {'gelDuke-Z3', 'salineDuke-Z3'}
        EEG.chanlocs(n_referential_leads).labels = 'Z3';
        EEG.refscheme = 'Z3';
    case 'salineNet-Z7'
        EEG.chanlocs(n_referential_leads).labels = 'Z7';
        EEG.refscheme = 'Z7';
    case 'gelDuke-0Z'
        EEG.chanlocs(n_referential_leads).labels = '0Z';
        EEG.refscheme = '0Z';
    case 'salineNet-5Z'
        EEG.chanlocs(n_referential_leads).labels = '5Z';
        EEG.refscheme = '5Z';
end

% Update impedance values - all auxiliary channels should also be NaN
if ~isempty(EEG.initimp)
    EEG.initimp(n_referential_leads:EEG.nbchan+1) = NaN;
end

if ~isempty(EEG.endimp)
    EEG.endimp(n_referential_leads:EEG.nbchan+1) = NaN;
end

% Update the number of channels
EEG.nbchan = size(EEG.data, 1);

%% Fill in the channel location info from a matching template
% this is not the digitized channel location for each individual, just the
% channel coordinates from montage templates

% Load an appropriate montage template
switch montage
    case {'gelDuke-Z3', 'salineDuke-Z3'}
        chanlocs = load('ANT_montage_templates.mat', 'chanlocs_dukeZ3');
        chanlocs = chanlocs.chanlocs_dukeZ3;
    case 'salineNet-Z7'
        chanlocs = load('ANT_montage_templates.mat', 'chanlocs_netZ7');
        chanlocs = chanlocs.chanlocs_netZ7;
    case 'gelDuke-0Z'
        chanlocs = load('ANT_montage_templates.mat', 'chanlocs_duke0Z');
        chanlocs = chanlocs.chanlocs_duke0Z;
    case 'salineNet-5Z'
        chanlocs = load('ANT_montage_templates.mat', 'chanlocs_net5Z');
        chanlocs = chanlocs.chanlocs_net5Z;
end
labels = {chanlocs.labels};

% Make sure that all channels in the template are contained in the data
EEG_labels = {EEG.chanlocs.labels};
for ii = 1:length(labels)
    assert(any(find(cellfun(@(x) strcmp(x, labels{ii}), EEG_labels))), ...
        ['Channel "', labels{ii}, '" is not found in the .cnt file but is expected under the "', montage, '" montage.'])
end

% Create an empty chanlocs using the same fields as the template chanlocs
fns = fieldnames(chanlocs)';
fns{2, 1} = {};
tmp_chanlocs = struct(fns{:});

% Fill in the channel location info from the template
for ii = 1:EEG.nbchan
    current_label = EEG_labels{ii};
    template_idx = find(cellfun(@(x) strcmp(x, current_label), labels));
    if isempty(template_idx)
        % channel label not found in template, which can happen if there
        % are additional channels recorded such as bipolar electrodes
        tmp_chanlocs(ii).labels = current_label;
    else
        % use the location info from the template for the channel
        tmp_chanlocs(ii) = chanlocs(template_idx);
    end
end

% Update EEG.chanlocs with location info populated from the template
EEG.chanlocs = tmp_chanlocs;

end
