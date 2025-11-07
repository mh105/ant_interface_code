function cnt_files = ANT_validate_cnt(root_dir)
% ANT_VALIDATE_CNT Recursively find all .cnt files in a directory tree,
% then call eepv4_read_info() on each one to make sure the files are not corrupted

% Validate input
if nargin < 1 || ~isfolder(root_dir)
    error('Input must be a valid directory path.');
end

% Recursively find all .cnt files
fileList = dir(fullfile(root_dir, '**', '*.cnt'));

% Construct full file paths
cnt_files = fullfile({fileList.folder}, {fileList.name});

% Ensure column cell array (optional)
cnt_files = cnt_files(:);

% Loop through all cnt files
for ii = 1:length(cnt_files)
    [~, fname, ext] = fileparts(cnt_files{ii}); % Extract file name without path
    fprintf('Loading #%d of %d: %s%s\n', ii, numel(cnt_files), fname, ext);
    eepv4_read_info(cnt_files{ii});
end

disp(['Validation completed on all .cnt files under: ', root_dir])

end