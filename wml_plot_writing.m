clear all; close all; clc

% Set working directories.
rootDir = '/Volumes/Seagate/wml/';

% Create date-specific file name that indicates how many subjects.
datestring = '20210428';
filename = sprintf('wml_beh_data_write_%s', datestring);

% Load data.
load(fullfile(rootDir, 'wml-data', 'wml-data-beh-prelim-Spring2021', 'supportFiles', filename), 'data_write');

alphastat = 0.66; % to return 1 SD, for 95% CI use .05

color_DI = [0.8500 0.3250 0.0980]; %orange
coloralpha = .05;

% Set up plot and measure-specific details.
capsize = 0;
marker = 'o';
linewidth = 1.5;
linestyle = 'none';
markersize = 100;
xtickvalues = [1 2 3 4];
xlim_lo = min(xtickvalues)-0.5; xlim_hi = max(xtickvalues)+0.5;
fontname = 'Arial';
fontsize = 20;
fontangle = 'italic';
yticklength = 0;
xticklength = 0.05;

ylimlo = 2.25; ylimhi = 3.5;

% Get individual subject means for each day.
subjectlist = unique(data_write.subID);
for sub = 1:length(subjectlist)
    
    for day = 1:length(unique(data_write.day))
    
        clear idx;
        idx = find(data_write.subID == subjectlist(sub) & data_write.day == day);
        
        if isempty(idx)
            
            drawduration(sub, day) = NaN;
            
        else
            
            drawduration(sub, day) = nanmean(data_write.drawduration(idx));
            
        end
    
    end
    
end


%% Plot means and standard deviations, but including individual data.
clr = [randi(255, [10, 1]) randi(255, [10, 1]) randi(255, [10, 1])]./255;
figure(1)
hold on;

% Calculate mean and standard deviation across-subject, within-day.
DI_mean = [nanmean(drawduration(:, 1)) nanmean(drawduration(:, 2)) nanmean(drawduration(:, 3)) nanmean(drawduration(:, 4))] ;
DI_std = [nanstd(drawduration(:, 1)) nanstd(drawduration(:, 2)) nanstd(drawduration(:, 3)) nanstd(drawduration(:, 4))] ;

% Plot means (do this first for legend and then second to keep it on top layer).
xval = linspace(1, length(DI_mean), length(DI_mean));
% scatter(xval, DI_mean, 'Marker', 'o', 'SizeData', 2*markersize, 'MarkerFaceColor', color_DI, 'MarkerEdgeColor', color_DI)

% Individual data points for DI.
gscatter(repmat(1, [size(drawduration, 1) 1]), drawduration(:, 1), subjectlist, clr)
gscatter(repmat(2, [size(drawduration, 1) 1]), drawduration(:, 2), subjectlist, clr)
gscatter(repmat(3, [size(drawduration, 1) 1]), drawduration(:, 3), subjectlist, clr)
gscatter(repmat(4, [size(drawduration, 1) 1]), drawduration(:, 4), subjectlist, clr)

% Means (second time to put it on top layer).
scatter(xval, DI_mean, 'Marker', 'o', 'SizeData', 2*markersize, 'MarkerFaceColor', color_DI, 'MarkerEdgeColor', color_DI)
errorbar(xval, DI_mean, DI_std, 'Color', color_DI, 'LineWidth', linewidth, 'LineStyle', linestyle, 'CapSize', capsize);
% errorbar(xval, DnI_mean, DnI_std, 'Color', color_DnI, 'LineWidth', linewidth, 'LineStyle', linestyle, 'CapSize', capsize);

% xaxis
xax = get(gca, 'xaxis');
xax.Limits = [xlim_lo xlim_hi];
xax.TickValues = xtickvalues;
xax.TickDirection = 'out';
xax.TickLength = [xticklength xticklength];
xlabels = {'Day 1', 'Day 2', 'Day 3', 'Day 4'};
% xlabels = cellfun(@(x) strrep(x, ' ', '\newline'), xlabels, 'UniformOutput', false);
xax.TickLabels = xlabels;
xax.FontName = fontname;
xax.FontSize = fontsize;
xax.FontAngle = fontangle;

% yaxis
yax = get(gca,'yaxis');
yax.Limits = [ylimlo ylimhi];
yax.TickValues = [ylimlo (ylimlo+ylimhi)/2 ylimhi];
yax.TickDirection = 'out';
yax.TickLength = [yticklength yticklength];
yax.TickLabels = {num2str(ylimlo, '%2.2f'), num2str((ylimlo+ylimhi)/2, '%2.2f'), num2str(ylimhi, '%2.2f')};
yax.FontName = fontname;
yax.FontSize = fontsize;

% general
a = gca;
%     a.TitleFontWeight = 'normal';
box off
%
legend('Location', 'eastoutside')
legend('boxoff');

a.YLabel.String = 'Draw Duration (seconds)';
a.YLabel.FontSize = fontsize;
a.YLabel.FontAngle = fontangle;
pbaspect([1 1 1])

%     pos=get(gca,'Position');
%     pos1=pos-[0 .02 0 0];
%     set(gca,'Position', pos1);

% Write.
% if strcmp(save_figures, 'yes')

print(fullfile(rootDir, 'wml-data', 'wml-data-beh-prelim-Spring2021', 'plots', 'plot_write'), '-dpng')
print(fullfile(rootDir, 'wml-data', 'wml-data-beh-prelim-Spring2021', 'plots', 'eps', 'plot_write'), '-depsc')

% end

hold off;

%% Plot rate of change, but including individual data.
