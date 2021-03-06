clear all; close all; clc;

% Set working directories.
rootDir = '/Volumes/Seagate/wml/';

% Get contents of the directory where the measures are stored.
grp_contents = dir(fullfile(rootDir, 'wml-data', 'wml-data-beh-prelim-Spring2021', 'data', '*test_gen_day*.txt'));

% Remove the '.' and '..' files.
grp_contents = grp_contents(arrayfun(@(x) x.name(1), grp_contents) ~= '.');

for s = 1:size(grp_contents, 1)
    %
    %     % Get filenames of letter/shape data for this subject.
    %     sub_contents = dir(fullfile(grp_contents(s).folder, grp_contents(s).name, '*practice*.txt'));
    %
    %     % Remove the '.' and '..' files.
    %     sub_contents = sub_contents(arrayfun(@(x) x.name(1), sub_contents) ~= '.');
    %
    %     % Remove the errors directory.
    %     sub_contents = sub_contents(arrayfun(@(x) x.name(1), sub_contents) ~= 'e');
    
    if ~isempty(grp_contents(s))
        
        %         scount = scount + 1;
        %
        %         % Grab subID.
        %         sub(scount) = str2num(grp_contents(s).name(end-2:end));
        
        % Display current sub ID.
        disp(grp_contents(s).name)
        
        %         % Read in letter/shape recognition data for this subject for each file (i.e., day).
        %         for day = 1:size(sub_contents, 1)
        
        data_temp = readtable(fullfile(grp_contents(s).folder, grp_contents(s).name));
        
        %             % Some earlier versions of the behavioral testing code outputted an empty column named
        %             % textItem. If this is one of those outputs, remove that column.
        %             if sum(strcmp('textItem', data_temp.Properties.VariableNames)) ~= 0
        %
        %                 data_temp.textItem = [];
        %
        %             end
        
        % When there are repeat trials, Matlab reads in the subID
        % column as a string. If this is one of those cases, change
        % subID from string to double.
        if strcmp(class(data_temp.subID), 'cell')
            
            data_temp.subID = str2double(data_temp.subID);
            
        end
        
        % Check to see where the repeat record(s) start and end.
        idx_start = find(isnan(data_temp.subID)) + 1;
        idx_end = length(data_temp.subID);
        
        % Identify which stimuli were repeated and replace the first
        % occurence of each stimulus with this repeat occurence.
        for repeat_trial = idx_start:idx_end
            idx_stim_row = find(strcmp(data_temp.imageFile(repeat_trial), data_temp.imageFile(1:repeat_trial-2)));
            data_temp(idx_stim_row, :) = data_temp(repeat_trial, :);
        end
        data_temp(idx_start-1:idx_end, :) = [];
        
        %             % Add column for group.
        %             g = training_group(find(subID == sub(scount)));
        %             data_temp.group = repmat(g, [size(data_temp, 1) 1]);
        %             clear g;
        
        % Add column for day.
        day = str2num(grp_contents(s).name(end-4));
        data_temp.day = repmat(day, [size(data_temp, 1) 1]);
        
        % If data_recog exists, append; if not, create.
        if s == 1 && day == 1
            
            % Create data_out array.
            data_recog = data_temp;
            
        else
            
            % Concatenate this array with the previous subject's array.
            data_recog = cat(1, data_recog, data_temp);
            
        end
        
        clear data_temp
        
    end
    
end


% Find rows that correspond to target observations.
idx_target = contains(data_recog.imageFile, 'S');

% Find rows that correspond to distractor observations.
idx_distractor = contains(data_recog.imageFile, 'D');

% Find rows that correspond to "yes" responses.
idx_yes = strcmp(data_recog.response, 'j');

% Find rows that correspond to "no" responses.
idx_no = strcmp(data_recog.response, 'f');

% Create new column: truepositive.
data_recog.truepositive = (idx_target + idx_yes) == 2;

% Create new column: falsepositive.
data_recog.falsepositive = (idx_distractor + idx_yes) == 2;

% Create new column: falsenegative.
data_recog.truenegative = (idx_target + idx_no) == 2;

% Create new column: truenegative.
data_recog.truenegative = (idx_distractor + idx_no) == 2;

% Create new column: acc.
data_recog.acc = (data_recog.truepositive == 1) | (data_recog.truenegative == 1);

% Find incorrect responses.
idx_incorrect = find(data_recog.acc == 0);

% Change RT value to NaN for observations where the response was incorrect.
data_recog.RT(idx_incorrect) = NaN;

% Remove outliers.
idx_above = find(data_recog.RT > (nanmean(data_recog.RT)+3*nanstd(data_recog.RT)));
idx_below = find(data_recog.RT < (nanmean(data_recog.RT)-3*nanstd(data_recog.RT)));
data_recog(cat(1, idx_above, idx_below), :) = [];

% Create date-specific file name that indicates how many subjects.
filename = sprintf('WML_beh_data_test_gen_%s', datestr(now,'yyyymmdd'));

% Save all variables.
save(fullfile(rootDir, 'wml-data', 'wml-data-beh-prelim-Spring2021', 'supportFiles', filename), 'data_recog');

% Save as a CSV file.
writetable(data_recog, fullfile(rootDir, 'wml-data', 'wml-data-beh-prelim-Spring2021', 'supportFiles', [filename '.csv']))
