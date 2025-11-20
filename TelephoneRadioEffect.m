function y_radio = TelephoneRadioEffect(y, Fs)
% y_radio = TelephoneRadioEffect(y, Fs)
% Simulates a telephone / radio voice:
%  - band-pass 300–3400 Hz
%  - soft saturation
%  - low-level noise

    % Ensure column vector
    y = y(:);

    % 1) Band-pass filter: telephone band (300–3400 Hz)
    f_low  = 300;   % Hz
    f_high = 3400;  % Hz
    Wn = [f_low, f_high] / (Fs/2);   % normalized cutoff frequencies

    % 4th-order Butterworth band-pass
    [b, a] = butter(4, Wn, 'bandpass');
    y_tel = filter(b, a, y);

    % 2) Soft saturation (nonlinear distortion)
    y_sat = y_tel + 0.3 * (y_tel.^3);

    % 3) Add low-level white noise
    noise_level = 0.01;         % adjust if needed
    noise = noise_level * randn(size(y_sat));

    y_radio = y_sat + noise;

    % Normalization
    y_radio = y_radio ./ (max(abs(y_radio)) + eps);
end
