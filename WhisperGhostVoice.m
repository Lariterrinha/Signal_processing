function y_whisper = WhisperGhostVoice(y, Fs)
% y_whisper = WhisperGhostVoice(y, Fs)
% Creates a whisper / ghost-like voice by randomizing the phase
% in the short-time Fourier transform (STFT).
%
% Requires: TFCT(x, Nfft, Nwin, hop) and TFCTInv(D, Nfft, Nwin, hop)

    % Ensure row vector for TFCT (your implementation uses row)
    y = y(:).';
    
    % STFT parameters
    Nfft  = 1024;
    Nwin  = Nfft;
    hop   = Nfft/4;   % must be consistent with PVoc/TFCT code

    % STFT of the signal
    D = TFCT(y, Nfft, Nwin, hop);   % each column = one frame

    % Magnitude
    Mag = abs(D);

    % Random phase in [0, 2*pi)
    phase_rand = exp(1j * 2*pi * rand(size(D)));

    % New complex spectrum
    D_whisper = Mag .* phase_rand;

    % Inverse STFT
    y_whisper = TFCTInv(D_whisper, Nfft, Nwin, hop);

    % Back to column vector
    y_whisper = y_whisper(:);

    % Normalization
    y_whisper = y_whisper ./ (max(abs(y_whisper)) + eps);
end
