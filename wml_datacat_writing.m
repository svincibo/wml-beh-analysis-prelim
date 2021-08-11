clear all; close all; clc

% Set working directories.
rootDir = '/Volumes/Seagate/wml/';

% Get contents of the directory where the measures are stored.
grp_contents = dir(fullfile(rootDir, 'wml-data', 'wml-data-beh-prelim-Spring2021', 'data', '*train_*.txt'));

% Remove the '.' and '..' files.
grp_contents = grp_contents(arrayfun(@(x) x.name(1), grp_contents) ~= '.');

% % Remove the temp not in use files.
% grp_contents = grp_contents(arrayfun(@(x) x.name(1), grp_contents) ~= 'n');

% scount = 0;
for s = 1:size(grp_contents, 1)
    
%     % Get filenames of letter/shape data for this subject.
%     sub_contents = dir(fullfile(grp_contents(s).folder, grp_contents(s).name));
%     
%     % Remove the '.' and '..' files.
%     sub_contents = sub_contents(arrayfun(@(x) x.name(1), sub_contents) ~= '.');
    
    if ~isempty(grp_contents(s))
        
%         scount = scount + 1;
        
%         % Grab subID.
%         sub(scount) = str2num(grp_contents(s).name(4:5));
        
        % Display current sub ID.
        disp(grp_contents(s).name)
        
%         % Read in writing data for this subject for each file (i.e., day).
%         for day = 1:size(sub_contents, 1)
            
            data_temp = readtable(fullfile(grp_contents(s).folder, grp_contents(s).name));
            
            % If data_recog exists, append; if not, create.
            if s == 1
                
                % Create data_out array.
                data_write = data_temp;
                
            else
                
                % Concatenate this array with the previous subject's array.
                data_write = cat(1, data_write, data_temp);
                
            end
            
            clear data_temp
            
%         end
        
    end
    
end

% Add header because readtable isn't recognizing the header in the txt files for some reason (Oct 2020).
data_write.Properties.VariableNames = {'subID', 'group', 'day', 'symbolname', 'block', 'trial', 'drawduration', 'trialduration'};

% % Find WD observations and remove.
% idx_WD = (data_write.group == 3);
% data_write(idx_WD, :) = [];

% Find DI observations.
% idx_DI = (data_write.group == 1);
data_write_DI = data_write;%(idx_DI, :);
% Get lower and upper bound.
idx_above = find(data_write_DI.drawduration > (nanmean(data_write_DI.drawduration)+3*nanstd(data_write_DI.drawduration)));
idx_below = find(data_write_DI.drawduration < (nanmean(data_write_DI.drawduration)-3*nanstd(data_write_DI.drawduration)));
% Remove outliers in DI.
data_write_DI(cat(1, idx_above, idx_below), :) = [];

% % Find DnI observations.
% idx_DnI = (data_write.group == 2);
% data_write_DnI = data_write(idx_DnI, :);
% % Get lower and upper bound.
% idx_above = find(data_write_DnI.drawduration > (nanmean(data_write_DnI.drawduration)+3*nanstd(data_write_DnI.drawduration)));
% idx_below = find(data_write_DnI.drawduration < (nanmean(data_write_DnI.drawduration)-3*nanstd(data_write_DnI.drawduration)));
% % Remove outliers in DI.
% data_write_DnI(cat(1, idx_above, idx_below), :) = [];

% Recombine.
clear data_write
data_write = cat(1, data_write_DI); %, data_write_DnI);
clear data_write_DI %data_write_DnI

% Create date-specific file name that indicates how many subjects.
filename = sprintf('WML_beh_data_write_%s', datestr(now,'yyyymmdd'));

% Save all variables.
save(fullfile(rootDir, 'wml-data', 'wml-data-beh-prelim-Spring2021', 'supportFiles', filename), 'data_write');

% Save as a CSV file.
writetable(data_write, fullfile(rootDir, 'wml-data', 'wml-data-beh-prelim-Spring2021', 'supportFiles', [filename '.csv']))

