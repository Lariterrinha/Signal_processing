function y_trio = HarmonicDuoTrio(y, Fs)
% y_trio = HarmonicDuoTrio(y, Fs)
% Creates a harmonic trio: original voice + 2 pitch-shifted copies
% Uses the phase vocoder function PVoc(x, rapp, Nfft, Nwind).

    % Ensure column vector
    y = y(:);

    % Vocoder parameters
    Nfft  = 1024;
    Nwind = Nfft;

    % Voice 2: slightly higher pitch (factor 4/3)
    a1 = 4;
    b1 = 3;
    yvoc1 = PVoc(y, a1/b1, Nfft, Nwind);
    y2 = resample(yvoc1, a1, b1);

    % Voice 3: slightly lower pitch (factor 5/4)
    a2 = 5;
    b2 = 4;
    yvoc2 = PVoc(y, a2/b2, Nfft, Nwind);
    y3 = resample(yvoc2, a2, b2);

    % Adjust lengths
    Lmin = min([length(y), length(y2), length(y3)]);
    y1n = y(1:Lmin);
    y2n = y2(1:Lmin);
    y3n = y3(1:Lmin);

    % Normalize each voice
    y1n = y1n ./ (max(abs(y1n)) + eps);
    y2n = y2n ./ (max(abs(y2n)) + eps);
    y3n = y3n ./ (max(abs(y3n)) + eps);

    % Sum: harmonic trio
    y_trio = y1n + y2n + y3n;

    % Global normalization
    y_trio = y_trio ./ (max(abs(y_trio)) + eps);
end
