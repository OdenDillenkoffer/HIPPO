%New script for how Victoria explained how to do this research

%I should refactor everything to make it more readable and remove excess
%files

%call ECG before this file, not all code has been refactored.

addpath("functions\frequency decomposition\");
%add function path
fs = 1200;
%load("\Filters\CombIIRforn60.mat")
%designed comb filter for data

%Not using comb yet, just want to visualize resp data vs muscle

% respirationDecompose.m
% Decomposes the Airflow signal from dataMAll for each load condition
% using decomposeSinusoid, then plots original + fit + each component

Fs = 1200;                          % Sampling frequency (Hz)
loadLabels = {'No Load', 'Medium Load', 'High Load'};
numLoads = 3;
numComponents = 3;

% --- Split dataMAll into the three load conditions ---
% dataMAll is all three loads stacked vertically with equal row counts
totalRows = size(dataMAll, 1);
rowsPerLoad = floor(totalRows / numLoads);  % Equal rows per load confirmed

% Find the Airflow column index in signalNames
airflowCol = find(strcmp(signalNames, 'Airflow'));

figure;
initGuess = [2,   1,   0.5,  ...   % amplitudes
             0.3, 0.6, 1.0,  ...   % frequencies (Hz)
             0,   0,   0,    ...   % phases
             0,   0,   0];         % start times
for i = 1:numLoads

    % --- Extract this load's rows ---
    rowStart = (i - 1) * rowsPerLoad + 1;
    rowEnd   =  i      * rowsPerLoad;
    loadData = dataMAll(rowStart:rowEnd, :);

    % --- Pull Airflow signal and build time vector ---
signal = loadData(1:rowsPerLoad, airflowCol)';
t      = (0:rowsPerLoad-1)' / Fs;
signalZ = (signal - mean(signal)) / std(signal);  % now unit variance, zero mean
    % --- Run decomposition ---
    [estParams, mse, fittedSignal] = decomposeSinusoid(t, signalZ, Fs, numComponents, initGuess);

    % --- Extract parameters for individual components ---
    amps       = estParams(1:numComponents);
    freqs      = estParams(numComponents   + 1 : 2*numComponents);
    phases     = estParams(2*numComponents + 1 : 3*numComponents);
    startTimes = estParams(3*numComponents + 1 : 4*numComponents);

    % --- Compute each sinusoid component individually ---
    % Replicating the delayed activation logic from sum_sinusoids_with_activation
    components = zeros(rowsPerLoad, numComponents);
    for k = 1:numComponents
        activeMask = t >= startTimes(k);        % Only active after start time
        components(activeMask, k) = amps(k) .* sin(2 * pi * freqs(k) .* (t(activeMask) - startTimes(k)) + phases(k));
    end

    % --- Plot ---
    subplot(numLoads, 1, i);
    plot(t, signal, 'k', 'LineWidth', 1.5, 'DisplayName', 'Original Airflow');
    hold on;
    plot(t, fittedSignal, 'r--', 'LineWidth', 2, 'DisplayName', sprintf('Fitted (MSE = %.4f)', mse));

    % Plot each component with a distinct color
    componentColors = {'b', 'm', 'g'};
    for k = 1:numComponents
        plot(t, components(:, k), ...
            componentColors{k}, ...
            'LineWidth', 1, ...
            'DisplayName', sprintf('Component %d: %.3f Hz', k, freqs(k)));
    end

    hold off;
    title(sprintf('Airflow Decomposition — %s', loadLabels{i}));
    xlabel('Time (s)');
    ylabel('Airflow');
    legend('Location', 'best');
    grid on;
end

sgtitle('Respiration Sinusoid Decomposition by Load Condition');


