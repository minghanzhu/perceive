function [pow,f,rpow,lpow]=perceive_fft(data,fs,tw)
% PERCEIVE_FFT Compute power spectral density using Welch's method
%
% Inputs:
%   data - Input signal matrix (rows: channels, columns: samples)
%   fs   - Sampling frequency in Hz
%   tw   - Time window length in samples (default: fs, i.e., 1 second)
%
% Outputs:
%   pow  - Power spectral density estimate for each channel
%   f    - Frequency vector corresponding to pow
%   rpow - Relative power (normalized to 5-45Hz and 55-95Hz bands)
%   lpow - Log-fitted power spectrum using perceive_fftlogfitter
%
% Uses Welch's method with 50% overlap and Hanning window for robust
% spectral estimation while reducing variance and spectral leakage.

% Set default window length to 1 second if not specified
if ~exist('tw','var')
    tw = fs;
end

% Process each channel separately
for a = 1:size(data,1)
    % Calculate power spectral density using Welch's method
    % Parameters:
    % - Hanning window of length tw
    % - 50% overlap between segments
    % - Number of FFT points = tw
    % - Sampling frequency = fs
    [pow(a,:),f] = pwelch(data(a,:),hanning(round(tw)),round(tw*0.5),round(tw),fs);
    
    % Calculate relative power by normalizing to sum of specific frequency bands
    % Excludes 45-55 Hz (likely power line noise) from normalization
    rpow(a,: ) = 100.*pow(a,:)./sum(pow(a,perceive_sc(f,[5:45 55:95])));
    
    % Attempt to fit a log curve to the power spectrum
    % This can fail gracefully if fitting is not possible
    try
        lpow(a,:)= perceive_fftlogfitter(f,pow(a,:));
    end
end
