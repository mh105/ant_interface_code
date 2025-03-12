function [ fastscan ] = ANT_MNE_fastscan(pcfn, markfn, fsfn, filepath, montage, criteria, verbose)
%
% ANT MNE CODES - FASTSCAN
%
% - function used to prepare the digitization of electrode locations from
% Polhemus FastScanII scannner into data arrays and electrode labels to be
% read by mne.channels.read_dig_montage to create the montage for
% assembling a _raw.fif file for input in mne.gui.coregistration when
% generating the -trans.fif file during forward modeling in MNE python.
%
% - updated to support 64-channel+EOG Waveguard equidistant cap as well as
% the 129-channel Saline Waveguard Net cap in this function.
%
% Last edit: Alex He 05/27/2024
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Inputs:
%           - pcfn:         filename of the .mat file exported from
%                           Polhemus FastScanII software containing the
%                           point clouds of the head surface as "Cloud of
%                           Points" (not triangulation face indices).
%
%           - markfn:       filename of the .txt file exported from
%                           Polhemus FastScanII software (in a separate
%                           step from exporting the point cloud) containing
%                           the coordinates of the markers manually placed
%                           by RAs according to the instruction manual. It
%                           must follow a certain order when placing the
%                           markers in the Polhemus FastScanII software in
%                           order to be read correctly.
%
%           - fsfn:         filename of the .mat file created by this
%                           function containing the various electrode and
%                           fiducial landmark coordinates both in native
%                           FastScan acquisition coordinate and in the
%                           newly transformed Waveguard template coordinate
%                           system, which has the origin (0,0,0) in the
%                           center of the head. This filename typically
%                           should have the same naming as pcfn and markfn,
%                           but with a _dig suffix appended behind to
%                           indicate it contains information about
%                           digitization of electrodes. However, you can
%                           give it arbitrary filename in this function.
%
%                           This same fsfn filename will also be used to
%                           name the .csv file exported from this function
%                           containing the digitization electrode
%                           coordinates and fiducial landmark coordinates
%                           read by functions in ANT_MNE_python_util.py
%                           to create the digitized montage object in MNE
%                           python.
%
%           - filepath:     full path to the folder containing the FastScan
%                           exported files (.mat and .txt) as well as the
%                           location to save the output quality-check
%                           figures produced from this function and the
%                           final fastscan structure (name specified by
%                           fsfn) to be saved to a .mat file.
%
%           - montage:      which Waveguard equidistant montage cap was
%                           used for the Fastscan.
%                           default: 'dukeZ3'
%
%           - criteria:     a 1x2 vector specifying the tolerable ranges of
%                           angle deviation and distance deviation in
%                           transforming from FastScan native coordinate
%                           system to the Waveguard coordinate system.
%                           default: [2, 0.2]
%
%           - verbose:      whether print messages and plotting during
%                           processing subject's electrode location files
%                           default: true
%
% Output:
%           - fastscan:     a structure containing all information of the
%                           digitization of electrodes acquired by Polhemus
%                           FastScanII scanner. The fields of this
%                           structure are as following:
%
%                           fastscan.head
%                               - point cloud of head surface
%                           fastscan.electrode
%                               - coordinates of electrodes in the native
%                               FastScan coordinate system
%                           fastscan.landmark
%                               - coordinates of right preauricular point,
%                               nasion, and left preauricular point in the
%                               native FastScan coordinate system
%                           fastscan.electrode_waveguard_xyz
%                               - coordinates of electrodes in the new
%                               Waveguard configuration coordinate system
%                           fastscan.landmark_waveguard_xyz
%                               - coordinates of right preauricular
%                               point, nasion, and left preauricular point
%                               in the new Waveguard configuration
%                               coordinate system
%                           fastscan.elc_labels
%                               - names of the channels in both
%                               fastscan.electrode and
%                               fastscan.electrode_waveguard_xyz
%                           fastscan.landmark_labels
%                               - names of the fiducial landmarks in both
%                               fastscan.landmark and
%                               fastscan.landmark_waveguard_xyz
%                           fastscan.chanlocs_subject
%                               - a structure containing the electrode
%                               coordinates in the new Waveguard
%                               configuration coordinate system for the
%                               subject. Note that this is not exactly the
%                               same electrode order as EEG.data because of
%                               the position of the reference electrode. In
%                               order to integrate this with an EEGLAB
%                               structure (EEG) for the field chanlocs,
%                               re-ordering should be done as in the
%                               ANT_interface_setmontage() function.
%                           fastscan.chanlocs_template
%                               - a structure containing the electrode
%                               coordinates of the Waveguard template
%                               contained in the field chanlocs in an
%                               EEGLAB structure (EEG) obtained from
%                               calling ANT_interface_readcnt.m function
%                           fastscan.chanlocs_template_fastscan_order
%                               - same positions as chanlocs_template, but
%                               re-ordered to the same ordering as the
%                               order of electrodes marked in Polhemus
%                               FastScanII software (i.e., the order of
%                               fastscan.electrode,
%                               fastscan.electrode_waveguard_xyz, and
%                               fastscan.elc_labels)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if nargin < 5
    montage = 'dukeZ3';
    criteria = [2,0.2];
    verbose = true;
elseif nargin < 6
    criteria = [2,0.2];
    verbose = true;
elseif nargin < 7
    verbose = true;
end

angle_tol = criteria(1);
distance_tol = criteria(2);

% addpath to the appropriate folders
try
    SleepEEG_addpath(matlabroot);
    
    ANTinterface_path = which('ANT_MNE_fastscan');
    temp = strsplit(ANTinterface_path, 'ANT_MNE_fastscan.m');
    ANTinterface_path = temp{1};
    
catch
    % if using SleepEEG_addpath() fails, we will assume the current directory
    % has the ANT_MNE_fastscan.m or at least the folder containing it has
    % been added to path when calling this function. We will try to addpath to
    % EEGLAB directly.
    
    ANTinterface_path = which('ANT_MNE_fastscan');
    temp = strsplit(ANTinterface_path, 'ANT_MNE_fastscan.m');
    ANTinterface_path = temp{1};
    
    % Add path to EEGLAB
    addpath(fullfile(ANTinterface_path, 'eeglab14_1_2b'))
end

% Add paths to dependent EEGLAB functions
eeglabpath = which('eeglab');
temp = strsplit(eeglabpath, 'eeglab.m');
addpath(fullfile(temp{1}, 'functions', 'sigprocfunc'))
addpath(fullfile(temp{1}, 'functions', 'guifunc'))
addpath(fullfile(temp{1}, 'functions', 'adminfunc'))

% Set warning of graphical display errors in command window to off
warning('off', 'MATLAB:callback:error')

% Use default naming of fsfn
if isempty(fsfn)
    temp = strsplit(pcfn, '.mat');
    fsfn = [temp{1},'_dig.mat'];
end

% Extract a general fileID for saved figures
temp = strsplit(fsfn, '.mat');
fileID = temp{1};

%% Visualize the data point clouds and confirm anatomical landmarks
fsfn = [fileID '.mat'];
fsfn_full = fullfile(filepath, fsfn);

if exist(fsfn_full, 'file') == 2 % if already on disk, load it
    if verbose
        disp(' ')
        disp([fsfn, ' is already on disk. Loading from:'])
        disp(' ')
        disp(fsfn_full)
    end
    load(fsfn_full, 'fastscan')
else
    if verbose
        disp(' ')
        disp([fsfn, ' is not created yet.'])
        disp(' ')
        disp('We will now create it from the .mat and .txt files from Polhemus FastScanII...')
    end
    
    % Load the exported files from Polhemus FastScanII
    pcloud = load(fullfile(filepath, pcfn));
    
    fileID_f = fopen(fullfile(filepath, markfn),'r');
    startRow = 4;
    formatSpec = '%10f%10f%f%[^\n\r]';
    dataArray = textscan(fileID_f, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID_f);
    markers = [dataArray{1:end-1}];
    clearvars filename startRow formatSpec fileID_f dataArray ans;
    %     markers = readtable(fullfile(filepath, markfn));
    %     markers = table2array(markers);
    
    % Show the point cloud of head surfaces
    figure
    set(gcf, 'units', 'pixels', 'Position', [0 0 1400 1000]);
    pcshow(pcloud.Points');
    hold on
    pcshow([0,0,0], 'g', 'MarkerSize', 6000)
    grid off; axis off
    
    % Display the landmarks
    pcshow(markers, 'w', 'MarkerSize', 5000);
    
    % ------------------
    % Manual checkpoint!
    % ------------------
    % Check if the first three correspond to anatomical landmarks
    landmarks = markers(1:3, :);
    ldindex = 1:3;
    pcshow(landmarks, 'r', 'MarkerSize', 5000);
    title('Head Surface, Electrodes, and Anatomical Landmarks', 'FontSize', 16)
    endsearch = input('Are the anatomical landmarks correctly colored red? (y/n): ', 's');
    if strcmpi(endsearch, 'n')
        % try the last three as anatomical landmarks
        hold on
        pcshow(landmarks, 'k', 'MarkerSize', 5000);
        landmarks = markers(end-2:end, :);
        ldindex = size(markers,1)-2:size(markers,1);
        hold on
        pcshow(landmarks, 'r', 'MarkerSize', 5500);
        endsearch = input('What about now, are the anatomical landmarks correctly colored red? (y/n): ', 's');
        if strcmpi(endsearch, 'n')
            % If still not, it means the electrode ordering is messed up!
            save(fullfile(filepath, [fileID '_landmark_order_debug_workspace']))
            error('Manual check failed. Workspace is saved. Please debug...')
            %             hold on
            %             pcshow(landmarks, 'k', 'MarkerSize', 5000);
            %             % Accept inputs for three landmark XYZ values
            %             XYZvalue = input('Please enter the XYZ value of first landmark separated by comma (X,Y,Z): ', 's');
            %             loc(1,:) = cellfun(@str2double, strsplit(XYZvalue, [" ",',']));
            %             XYZvalue = input('Please enter the XYZ value of second landmark separated by comma (X,Y,Z): ', 's');
            %             loc(2,:) = cellfun(@str2double, strsplit(XYZvalue, [" ",',']));
            %             XYZvalue = input('Please enter the XYZ value of third landmark separated by comma (X,Y,Z): ', 's');
            %             loc(3,:) = cellfun(@str2double, strsplit(XYZvalue, [" ",',']));
            %
            %             % Find these landmark points
            %             ldindex = [];
            %             landmarks = zeros(size(loc));
            %             for i = 1:size(markers,1)
            %                 for j = 1:size(loc,1)
            %                     if sum(abs(markers(i,:) - loc(j,:))) < 1
            %                         landmarks(j,:) = landmarks(i,:);
            %                         deleteindex = [deleteindex, i]; %#ok<AGROW>
            %                     end
            %                 end
            %             end
            %             hold on
            %             pcshow(landmarks, 'r', 'MarkerSize', 5500);
        end
    end
    close all
    
    %% Create a structure to store these XYZ values
    % remove the landmarks from markers, the remaining ones should be electrodes
    markers(ldindex, :) = [];
    fastscan = struct;
    fastscan.head = pcloud.Points;
    fastscan.electrode = markers;
    fastscan.landmark = landmarks;
    
    %% Visualize just the electrodes and landmarks and save the plot
    %
    %     figure
    %     pcshow(fastscan.electrode, 'w', 'MarkerSize', 2000);
    %     hold on
    %     pcshow(fastscan.landmark, 'r', 'MarkerSize', 4000);
    %     grid off; axis off
    %     title('Electrodes and Landmarks', 'FontSize', 16)
    %
    %     savefig(fullfile(dataDir, subID, 'fastscan', [fileID '_visual_elc.fig']))
    %     close all
    %
    %% Ridig transformation of Fastscan electrodes into Waveguard coordinates
    
    % Need to convert the XYZ to a new coordinate system with different origin
    % and direction vectors based on the Waveguard template in EEGLAB
    
    % We define the new 128-channel Waveguard coordinate system the following way:
    % - We find the centroid on the left side among LD3, LD4, and LC3, call
    % it Lmid; we find the centroid on the right side among RD3, RD4, and RC3
    % call it Rmid. We connect Lmid and Rmid, take the midpoint of this line as
    % the origin.
    % - Y direction is pointing in Lmid. Then we connect Z direction
    % as pointing towards the vertex electrode Z5. And X is normal to the plane
    % and pointing towards the front, such that Z1-Z4 should have positive X
    % values.
    
    % If the equidistant 64-channel cap is used:
    % - We find the centroid on the left side among 2LC, 3LC, and 3LB, call
    % it Lmid; we find the centroid on the right side among 2RC, 3RC, and 3RB
    % call it Rmid. We connect Lmid and Rmid, take the midpoint of this line as
    % the origin.
    % - Y direction is pointing in Lmid. Then we connect Z direction
    % as pointing towards the vertex point between 3Z and 4Z.
    % And X is normal to the plane and pointing towards the front,
    % such that 0Z-2Z should have positive X values.
    
    % FASTSCAN digitization in the old coordinate system (native tracker based)
    oldxyz = fastscan.electrode;
    
    % Electrodes in the Waveguard template coordinates (target coordinate system)
    load(fullfile(ANTinterface_path, 'ANT_montage_templates.mat')) %#ok<LOAD>
    switch montage
        case {'dukeZ3'}
            chanlocs_template = chanlocs_dukeZ3;
        case {'netZ7'}
            chanlocs_template = chanlocs_netZ7;
        case {'duke0Z'}
            chanlocs_template = chanlocs_duke0Z;
    end
    
    % Copy over the XYZ coordinates from the template into a matrix
    waveguard = zeros(length(chanlocs_template), 3);
    for ii = 1:length(chanlocs_template)
        waveguard(ii,1) = chanlocs_template(ii).X;
        waveguard(ii,2) = chanlocs_template(ii).Y;
        waveguard(ii,3) = chanlocs_template(ii).Z;
    end
    
    % Let's first visualize the involved electrodes in the Waveguard template. We
    % won't try to convert the Waveguard template coordinate system to this new
    % coordinate system as well since we are trying to emulate it. But it gives
    % us a sense of how good the approximation is in the coordiante system that
    % we are trying to mimic from.
    if verbose
        figure
        set(gcf, 'units', 'pixels', 'Position', [200 200 1600 600]);
        subplot(1,2,1)
        pcshow(waveguard, 'k', 'MarkerSize', 2000);
        xlabel('X'); ylabel('Y'), zlabel('Z')
        hold on
        switch montage
            case {'dukeZ3'}
                pcshow(waveguard(124,:), 'b', 'MarkerSize', 2000); % LD3
                pcshow(waveguard(125,:), 'b', 'MarkerSize', 2000); % LD4
                pcshow(waveguard(7,:), 'b', 'MarkerSize', 2000); % LC3
                pcshow(waveguard(50,:), 'b', 'MarkerSize', 2000); % RD3
                pcshow(waveguard(51,:), 'b', 'MarkerSize', 2000); % RD4
                pcshow(waveguard(40,:), 'b', 'MarkerSize', 2000); % RC3
                pcshow(waveguard(86,:), 'b', 'MarkerSize', 2000); % Z5
            case {'netZ7'}
                pcshow(waveguard(87,:), 'b', 'MarkerSize', 2000); % LD3
                pcshow(waveguard(88,:), 'b', 'MarkerSize', 2000); % LD4
                pcshow(waveguard(80,:), 'b', 'MarkerSize', 2000); % LC3
                pcshow(waveguard(119,:), 'b', 'MarkerSize', 2000); % RD3
                pcshow(waveguard(120,:), 'b', 'MarkerSize', 2000); % RD4
                pcshow(waveguard(112,:), 'b', 'MarkerSize', 2000); % RC3
                pcshow(waveguard(35,:), 'b', 'MarkerSize', 2000); % Z5
            case {'duke0Z'}
                pcshow(waveguard(25,:), 'b', 'MarkerSize', 2000); % 2LC
                pcshow(waveguard(29,:), 'b', 'MarkerSize', 2000); % 3LC
                pcshow(waveguard(27,:), 'b', 'MarkerSize', 2000); % 3LB
                pcshow(waveguard(26,:), 'b', 'MarkerSize', 2000); % 2RC
                pcshow(waveguard(30,:), 'b', 'MarkerSize', 2000); % 3RC
                pcshow(waveguard(28,:), 'b', 'MarkerSize', 2000); % 3RB
                pcshow(waveguard(4,:), 'b', 'MarkerSize', 2000); % 3Z
                pcshow(waveguard(5,:), 'b', 'MarkerSize', 2000); % 4Z
        end
        % Origin
        pcshow([0,0,0], 'm', 'MarkerSize', 2000);
        % Direction vectors
        plot3([0,100], [0,0], [0,0], 'r', 'LineWidth', 3)
        plot3([0,0], [0,100], [0,0], 'g', 'LineWidth', 3)
        plot3([0,0], [0,0], [0,100], 'b', 'LineWidth', 3)
        title('Waveguard Template', 'FontSize', 16)
        set(gca, 'Color', 'w')
        
        % Let's visualize these key electrodes in the FASTSCAN digitization
        subplot(1,2,2)
        pcshow(oldxyz, 'k', 'MarkerSize', 2000);
        xlabel('X'); ylabel('Y'), zlabel('Z')
        hold on
        pcshow(fastscan.landmark, 'r', 'MarkerSize', 4000);
        switch montage
            case {'dukeZ3'}
                pcshow(oldxyz(119,:), 'b', 'MarkerSize', 2000); % LD3
                pcshow(oldxyz(120,:), 'b', 'MarkerSize', 2000); % LD4
                pcshow(oldxyz(112,:), 'b', 'MarkerSize', 2000); % LC3
                pcshow(oldxyz(8,:), 'b', 'MarkerSize', 2000); % RD3
                pcshow(oldxyz(9,:), 'b', 'MarkerSize', 2000); % RD4
                pcshow(oldxyz(15,:), 'b', 'MarkerSize', 2000); % RC3
                pcshow(oldxyz(62,:), 'c', 'MarkerSize', 2000); % Z5
            case {'netZ7'}
                pcshow(oldxyz(120,:), 'b', 'MarkerSize', 2000); % LD3
                pcshow(oldxyz(121,:), 'b', 'MarkerSize', 2000); % LD4
                pcshow(oldxyz(113,:), 'b', 'MarkerSize', 2000); % LC3
                pcshow(oldxyz(8,:), 'b', 'MarkerSize', 2000); % RD3
                pcshow(oldxyz(9,:), 'b', 'MarkerSize', 2000); % RD4
                pcshow(oldxyz(15,:), 'b', 'MarkerSize', 2000); % RC3
                pcshow(oldxyz(63,:), 'c', 'MarkerSize', 2000); % Z5
            case {'duke0Z'}
                pcshow(oldxyz(57,:), 'b', 'MarkerSize', 2000); % 2LC
                pcshow(oldxyz(58,:), 'b', 'MarkerSize', 2000); % 3LC
                pcshow(oldxyz(53,:), 'b', 'MarkerSize', 2000); % 3LB
                pcshow(oldxyz(6,:), 'b', 'MarkerSize', 2000); % 2RC
                pcshow(oldxyz(7,:), 'b', 'MarkerSize', 2000); % 3RC
                pcshow(oldxyz(12,:), 'b', 'MarkerSize', 2000); % 3RB
                pcshow(oldxyz(31,:), 'b', 'MarkerSize', 2000); % 3Z
                pcshow(oldxyz(32,:), 'b', 'MarkerSize', 2000); % 4Z
        end
        % Origin
        pcshow([0,0,0], 'm', 'MarkerSize', 2000);
        % Direction vectors
        plot3([0,100], [0,0], [0,0], 'r', 'LineWidth', 3)
        plot3([0,0], [0,100], [0,0], 'g', 'LineWidth', 3)
        plot3([0,0], [0,0], [0,100], 'b', 'LineWidth', 3)
        title('FastScan Digitization', 'FontSize', 16)
        set(gca, 'Color', 'w')
    end
    
    % Find the bilateral midpoints
    switch montage
        case {'dukeZ3'}
            % Define centroids of LD3, LD4, LC3, and RD3, RD4, RC3
            Lmid = [mean([oldxyz(119,1), oldxyz(120,1), oldxyz(112,1)]),...
                mean([oldxyz(119,2), oldxyz(120,2), oldxyz(112,2)]),...
                mean([oldxyz(119,3), oldxyz(120,3), oldxyz(112,3)])];
            Rmid = [mean([oldxyz(8,1), oldxyz(9,1), oldxyz(15,1)]),...
                mean([oldxyz(8,2), oldxyz(9,2), oldxyz(15,2)]),...
                mean([oldxyz(8,3), oldxyz(9,3), oldxyz(15,3)])];
        case {'netZ7'}
            % Define centroids of LD3, LD4, LC3, and RD3, RD4, RC3
            Lmid = [mean([oldxyz(120,1), oldxyz(121,1), oldxyz(113,1)]),...
                mean([oldxyz(120,2), oldxyz(121,2), oldxyz(113,2)]),...
                mean([oldxyz(120,3), oldxyz(121,3), oldxyz(113,3)])];
            Rmid = [mean([oldxyz(8,1), oldxyz(9,1), oldxyz(15,1)]),...
                mean([oldxyz(8,2), oldxyz(9,2), oldxyz(15,2)]),...
                mean([oldxyz(8,3), oldxyz(9,3), oldxyz(15,3)])];
        case {'duke0Z'}
            % Define centroids of 2LC, 3LC, 3LB, and 2RC, 3RC, 3RB
            Lmid = [mean([oldxyz(57,1), oldxyz(58,1), oldxyz(53,1)]),...
                mean([oldxyz(57,2), oldxyz(58,2), oldxyz(53,2)]),...
                mean([oldxyz(57,3), oldxyz(58,3), oldxyz(53,3)])];
            Rmid = [mean([oldxyz(6,1), oldxyz(7,1), oldxyz(12,1)]),...
                mean([oldxyz(6,2), oldxyz(7,2), oldxyz(12,2)]),...
                mean([oldxyz(6,3), oldxyz(7,3), oldxyz(12,3)])];
    end
    
    % Find the new origin point
    neworigin = (Lmid + Rmid)./2;
    
    % Define vertex point
    switch montage
        case {'dukeZ3'}
            vertex = oldxyz(62, :);
        case {'netZ7'}
            vertex = oldxyz(63, :);
        case {'duke0Z'}
            % Use the mid point between 3Z and 4Z as vertex
            vertex = [mean([oldxyz(31,1), oldxyz(32,1)]),...
                mean([oldxyz(31,2), oldxyz(32,2)]),...
                mean([oldxyz(31,3), oldxyz(32,3)])];
    end
    
    % Display these centroid points
    if verbose
        hold on
        pcshow([Lmid;Rmid], 'c', 'MarkerSize', 2000);
        pcshow(vertex, 'c', 'MarkerSize', 2000);
        
        % Plot the directions of the new coordinate system
        plot3([Lmid(1), neworigin(1)], [Lmid(2), neworigin(2)], [Lmid(3), neworigin(3)], 'g', 'LineWidth', 3) % Y direction
        pcshow(neworigin, 'm', 'MarkerSize', 3000);
        plot3([neworigin(1), vertex(1)], [neworigin(2), vertex(2)], [neworigin(3), vertex(3)], 'b', 'LineWidth', 3) % Z direction
        newnosep = cross(Lmid-neworigin, vertex-neworigin)./100 + neworigin;
        plot3([newnosep(1), neworigin(1)], [newnosep(2), neworigin(2)], [newnosep(3), neworigin(3)], 'r', 'LineWidth', 3) % X direction
        set(gca, 'Color', 'w')
    end
    
    % Compute the new unit vectors XYZ
    newuniX = (newnosep-neworigin)./norm(newnosep-neworigin);
    newuniY = (Lmid-neworigin)./norm(Lmid-neworigin);
    newuniZ = (vertex-neworigin)./norm(vertex-neworigin);
    
    % Confirm that the new unit vectors are roughly orthogonal
    xy_off = abs(90 - atan2d(norm(cross(newuniX,newuniY)),dot(newuniX,newuniY)));
    yz_off = abs(90 - atan2d(norm(cross(newuniY,newuniZ)),dot(newuniY,newuniZ)));
    zx_off = abs(90 - atan2d(norm(cross(newuniZ,newuniX)),dot(newuniZ,newuniX)));
    if ~all([xy_off, yz_off, zx_off] < angle_tol) % off angle should be less than [angle_tol]degrees (default = 2deg)
        disp(['xy angle off: ', num2str(xy_off), 'deg'])
        disp(['yz angle off: ', num2str(yz_off), 'deg'])
        disp(['zx angle off: ', num2str(zx_off), 'deg'])
        error(['new coordinate direction vectors are not orthogonal (enough). off angle > ', num2str(angle_tol), 'deg. This is usually due to erroneous definition of Lmid or Rmid.'])
    end
    
    % Now transform electrode coordinates into the new Waveguard coordinate system
    newxyz = (oldxyz-neworigin) * [newuniX', newuniY', newuniZ'];
    
    % transform the landmarks as well
    newlandmark = (fastscan.landmark-neworigin) * [newuniX', newuniY', newuniZ'];
    
    % Visualize the electrode locations in the new Waveguard coordinate system
    if verbose
        figure
        set(gcf, 'units', 'pixels', 'Position', [200 200 1600 600]);
        subplot(1,2,1)
        pcshow(oldxyz, 'k', 'MarkerSize', 2000);
        xlabel('X'); ylabel('Y'), zlabel('Z')
        hold on
        pcshow(fastscan.landmark, 'r', 'MarkerSize', 4000);
        switch montage
            case {'dukeZ3'}
                pcshow(oldxyz(119,:), 'b', 'MarkerSize', 2000); % LD3
                pcshow(oldxyz(120,:), 'b', 'MarkerSize', 2000); % LD4
                pcshow(oldxyz(112,:), 'b', 'MarkerSize', 2000); % LC3
                pcshow(oldxyz(8,:), 'b', 'MarkerSize', 2000); % RD3
                pcshow(oldxyz(9,:), 'b', 'MarkerSize', 2000); % RD4
                pcshow(oldxyz(15,:), 'b', 'MarkerSize', 2000); % RC3
                pcshow(oldxyz(62,:), 'c', 'MarkerSize', 2000); % Z5
            case {'netZ7'}
                pcshow(oldxyz(120,:), 'b', 'MarkerSize', 2000); % LD3
                pcshow(oldxyz(121,:), 'b', 'MarkerSize', 2000); % LD4
                pcshow(oldxyz(113,:), 'b', 'MarkerSize', 2000); % LC3
                pcshow(oldxyz(8,:), 'b', 'MarkerSize', 2000); % RD3
                pcshow(oldxyz(9,:), 'b', 'MarkerSize', 2000); % RD4
                pcshow(oldxyz(15,:), 'b', 'MarkerSize', 2000); % RC3
                pcshow(oldxyz(63,:), 'c', 'MarkerSize', 2000); % Z5
            case {'duke0Z'}
                pcshow(oldxyz(57,:), 'b', 'MarkerSize', 2000); % 2LC
                pcshow(oldxyz(58,:), 'b', 'MarkerSize', 2000); % 3LC
                pcshow(oldxyz(53,:), 'b', 'MarkerSize', 2000); % 3LB
                pcshow(oldxyz(6,:), 'b', 'MarkerSize', 2000); % 2RC
                pcshow(oldxyz(7,:), 'b', 'MarkerSize', 2000); % 3RC
                pcshow(oldxyz(12,:), 'b', 'MarkerSize', 2000); % 3RB
                pcshow(oldxyz(31,:), 'b', 'MarkerSize', 2000); % 3Z
                pcshow(oldxyz(32,:), 'b', 'MarkerSize', 2000); % 4Z
        end
        % Origin
        pcshow([0,0,0], 'm', 'MarkerSize', 2000);
        % Direction vectors
        plot3([0,100], [0,0], [0,0], 'r', 'LineWidth', 3)
        plot3([0,0], [0,100], [0,0], 'g', 'LineWidth', 3)
        plot3([0,0], [0,0], [0,100], 'b', 'LineWidth', 3)
        title('FastScan Native Coordinate System', 'FontSize', 16)
        set(gca, 'Color', 'w')
        
        subplot(1,2,2)
        pcshow(newxyz, 'k', 'MarkerSize', 2000);
        xlabel('X'); ylabel('Y'), zlabel('Z')
        hold on
        pcshow(newlandmark, 'r', 'MarkerSize', 4000);
        switch montage
            case {'dukeZ3'}
                pcshow(newxyz(119,:), 'b', 'MarkerSize', 2000); % LD3
                pcshow(newxyz(120,:), 'b', 'MarkerSize', 2000); % LD4
                pcshow(newxyz(112,:), 'b', 'MarkerSize', 2000); % LC3
                pcshow(newxyz(8,:), 'b', 'MarkerSize', 2000); % RD3
                pcshow(newxyz(9,:), 'b', 'MarkerSize', 2000); % RD4
                pcshow(newxyz(15,:), 'b', 'MarkerSize', 2000); % RC3
                pcshow(newxyz(62,:), 'c', 'MarkerSize', 2000); % Z5
            case {'netZ7'}
                pcshow(newxyz(120,:), 'b', 'MarkerSize', 2000); % LD3
                pcshow(newxyz(121,:), 'b', 'MarkerSize', 2000); % LD4
                pcshow(newxyz(113,:), 'b', 'MarkerSize', 2000); % LC3
                pcshow(newxyz(8,:), 'b', 'MarkerSize', 2000); % RD3
                pcshow(newxyz(9,:), 'b', 'MarkerSize', 2000); % RD4
                pcshow(newxyz(15,:), 'b', 'MarkerSize', 2000); % RC3
                pcshow(newxyz(63,:), 'c', 'MarkerSize', 2000); % Z5
            case {'duke0Z'}
                pcshow(newxyz(57,:), 'b', 'MarkerSize', 2000); % 2LC
                pcshow(newxyz(58,:), 'b', 'MarkerSize', 2000); % 3LC
                pcshow(newxyz(53,:), 'b', 'MarkerSize', 2000); % 3LB
                pcshow(newxyz(6,:), 'b', 'MarkerSize', 2000); % 2RC
                pcshow(newxyz(7,:), 'b', 'MarkerSize', 2000); % 3RC
                pcshow(newxyz(12,:), 'b', 'MarkerSize', 2000); % 3RB
                pcshow(newxyz(31,:), 'b', 'MarkerSize', 2000); % 3Z
                pcshow(newxyz(32,:), 'b', 'MarkerSize', 2000); % 4Z
        end
        % Origin
        pcshow([0,0,0], 'm', 'MarkerSize', 2000);
        % Direction vectors
        plot3([0,100], [0,0], [0,0], 'r', 'LineWidth', 3)
        plot3([0,0], [0,100], [0,0], 'g', 'LineWidth', 3)
        plot3([0,0], [0,0], [0,100], 'b', 'LineWidth', 3)
        title('New Waveguard Coordinate System', 'FontSize', 16)
        set(gca, 'Color', 'w')
    end
    % Make sure that distance between preauricular points are not signicantly
    % altered during this coordiante system transformation
    preauc_distance = norm(newlandmark(1,:)-newlandmark(3,:)) - norm(fastscan.landmark(1,:)-fastscan.landmark(3,:));
    if ~(preauc_distance < distance_tol) % distance change should be less than [distance_tol]mm (default = 0.2mm)
        disp(['Preauricular point distance changed by: ', num2str(preauc_distance), 'mm'])
        error(['Distance between PA points significantly changed during coordiante transformation. Distance off > ', num2str(distance_tol), 'mm.'])
    end
    
    %% Now, let's do some quality control inspections
    % The next two steps have to be done manually...
    figure
    set(gcf, 'units', 'pixels', 'Position', [200 200 800 600]);
    scatter3(newxyz(:,1), newxyz(:,2), newxyz(:,3), 400, 'k', 'filled');
    axis equal
    rotate3d on
    xlabel('X'); ylabel('Y'), zlabel('Z')
    hold on
    scatter3(newlandmark(1,1), newlandmark(1,2), newlandmark(1,3), 600, 'r', 'filled');
    scatter3(newlandmark(2,1), newlandmark(2,2), newlandmark(2,3), 600, 'g', 'filled');
    scatter3(newlandmark(3,1), newlandmark(3,2), newlandmark(3,3), 600, 'b', 'filled');
    % Direction vectors
    plot3([0,100], [0,0], [0,0], 'r', 'LineWidth', 3)
    plot3([0,0], [0,100], [0,0], 'g', 'LineWidth', 3)
    plot3([0,0], [0,0], [0,100], 'b', 'LineWidth', 3)
    legend('Electrodes', 'Right PA', 'Nasion', 'Left PA', 'X', 'Y', 'Z')
    title('Landmarks in Waveguard Coordinates')
    set(gca, 'FontSize', 20)
    view(270, 90)
    
    % ------------------
    % Manual checkpoint!
    % ------------------
    checkok =  input('Do the anatomical landmarks look ok? (y/n): ', 's');
    if strcmpi(checkok, 'n')
        save(fullfile(filepath, [fileID '_landmark_debug_workspace']))
        error('Manual check failed. Workspace is saved. Please debug...')
    else
        % Save the plot as .png for reference
        figure(3)
        view(270, 90) % reset to top-down view point
        saveas(gcf, fullfile(filepath, [fileID '_landmark_check.png']))
        close all
    end
    
    %% Create a chanlocs structure for the subject
    % loads in the labels of fastscan electrodes done by manual labelling
    switch montage
        case {'dukeZ3'}
            chanlocs_template_fastscan_order = chanlocs_dukeZ3_fastscan_order;
        case {'netZ7'}
            chanlocs_template_fastscan_order = chanlocs_netZ7_fastscan_order;
        case {'duke0Z'}
            chanlocs_template_fastscan_order = chanlocs_duke0Z_fastscan_order;
    end
    chanlocs_subject_fastscan_order = chanlocs_template_fastscan_order;
    template_labels = {chanlocs_template.labels};
    for ii = 1:length(chanlocs_subject_fastscan_order)
        chanlocs_subject_fastscan_order(ii).X = newxyz(ii,1);
        chanlocs_subject_fastscan_order(ii).Y = newxyz(ii,2);
        chanlocs_subject_fastscan_order(ii).Z = newxyz(ii,3);
        chanlocs_subject_fastscan_order(ii).template_idx = find(cellfun(@(x) strcmp(x, chanlocs_subject_fastscan_order(ii).labels), template_labels));
    end
    
    % Convert to EEGLAB 2D polar coordinates for topoplot
    chanlocs_subject_fastscan_order = convertlocs(chanlocs_subject_fastscan_order, 'cart2all');
    
    % Make EEGLAB 2D topoplots of the electrodes in the FastScan order for:
    % 1) Waveguard template electrodes
    % 2) Digitization that was acquired for each subject
    % We want to manually compare the numbers are approximatelythe same at
    % all electrode positions to make sure no labeling error was made when
    % marking electrode positions with stylus pen in FastScanII software.
    
    figure;
    set(gcf, 'Position', [200 200 1600 800])
    
    % Waveguard template
    subplot(1,2,1)
    topoplot([],chanlocs_template_fastscan_order,'style','both','electrodes','ptsnumbers','emarker', {'.', 'k', 15, 1});
    L = findobj(gcf, 'type', 'Text');
    for ind = 1:length(chanlocs_template_fastscan_order)
        set(L(length(chanlocs_template_fastscan_order)+1-ind), 'FontSize', 14)
    end
    title([fileID ' Template Positions'], 'FontSize', 30, 'Interpreter', 'none')
    
    % FastScan Digitization
    subplot(1,2,2)
    topoplot([],chanlocs_subject_fastscan_order,'style','both','electrodes','ptsnumbers','emarker', {'.', 'k', 15, 1});
    L = findobj(gcf, 'type', 'Text');
    for ind = 1:length(chanlocs_subject_fastscan_order)
        set(L(length(chanlocs_subject_fastscan_order)+1-ind), 'FontSize', 14)
        set(L(length(chanlocs_subject_fastscan_order)+1-ind), 'Color', [0,0,1])
    end
    title([fileID ' Digitization Positions'], 'FontSize', 30, 'Color', [0,0,1], 'Interpreter', 'none')
    
    % ------------------
    % Manual checkpoint!
    % ------------------
    checkok =  input('Does the digitization have identical numbering order as the template? (y/n): ', 's');
    if strcmpi(checkok, 'n')
        save(fullfile(filepath, [fileID '_elcorder_debug_workspace']))
        error('Manual check failed. Workspace is saved. Please debug...')
    else
        % Save the plot as .png for reference
        saveas(gcf, fullfile(filepath, [fileID '_elcorder_check.png']))
        close all
    end
    
    %% Now that both landmark orders and electrode orders are vetted, store them
    % Digitization in Waveguard coordinates
    fastscan.electrode_waveguard_xyz = newxyz;
    fastscan.landmark_waveguard_xyz = newlandmark;
    
    % Digitization labels
    fastscan.elc_labels = {chanlocs_subject_fastscan_order.labels}';
    fastscan.landmark_labels = {'rpa'; 'nasion'; 'lpa'}; % Right Preauricular Point, Nasion, Left Preauricular Point
    
    % Re-order into the Waveguard template electrode order that is almost
    % the same as the collected EEG.data (05/27/2024: not exactly the same!)
    chanlocs_subject = chanlocs_subject_fastscan_order;
    for ii = 1:length(chanlocs_subject_fastscan_order)
        chanlocs_subject(chanlocs_subject_fastscan_order(ii).template_idx) = chanlocs_subject_fastscan_order(ii);
    end
    fastscan.chanlocs_subject = chanlocs_subject;
    
    % Waveguard template structures
    fastscan.chanlocs_template = chanlocs_template;
    fastscan.chanlocs_template_fastscan_order = chanlocs_template_fastscan_order;
    
    % Save the structure so we don't have to do these manual checkings again
    if verbose
        disp(' ')
        disp('FastScan digitization manual check completed, fastscan file saved to: ')
        disp(' ')
        disp(fsfn_full)
    end
    save(fsfn_full, 'fastscan')
    
end

%% Store in a format readable by Python
% We have confirmed the correctness of electrode labelling by
% transforming the digitization locations into EEGLAB 2D topoplot of
% the Waveguard coordinate system of the template. We are confident in the
% electrode and landmark labels.

% Rather than using the transformed locations, we can save the raw
% digitzation electrode + landmark locations in its native coordinate
% system based on the tracker. mne.channels.read_dig_montage will
% construct its own transformation based on the head coordinate system
% in MNE-Python, which is defined by the 3 anatomical landmarks.

% Now we just have to save these raw XYZ values and electrode +
% landmark labels to formats readable into creating Python arrays. We
% can then pass these arrays to mne.channels.read_dig_montage to create
% the montage object for mne.gui.coregistration, which is trying to
% create the _trans.fif file for forward modeling solution. We will save
% as .csv file here.

% First let's store the labels and XYZ values into a table.
fs_dig = table;
fs_dig.labels = char([fastscan.landmark_labels; fastscan.elc_labels]);
fs_dig.X = [fastscan.landmark(:,1); fastscan.electrode(:,1)];
fs_dig.Y = [fastscan.landmark(:,2); fastscan.electrode(:,2)];
fs_dig.Z = [fastscan.landmark(:,3); fastscan.electrode(:,3)];

% Write to .csv file
csvfn = fullfile(filepath, [fileID '.csv']);
writetable(fs_dig, csvfn, 'Delimiter', ',')

if verbose
    disp(' ')
    disp('Labels and XYZ values for sleepeeg_create_montage is saved to .csv file: ')
    disp(' ')
    disp(csvfn)
end

%%
% turn the warning setting back on
warning('on', 'MATLAB:callback:error')

end
