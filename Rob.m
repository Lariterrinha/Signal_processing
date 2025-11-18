function yrob = Rob(y, fc, Fs)
% yrob = Rob(y, fc, Fs)
% Robotisation par modulation en anneau (ring modulation)
%
% y  : signal d'entrée (vecteur)
% fc : fréquence de la porteuse (Hz)
% Fs : fréquence d'échantillonnage (Hz)

    % Garante vetor coluna
    y = y(:);
    N = length(y);
    n = (0:N-1).';

    % Porteuse complexe e^{j 2 pi fc n / Fs}
    c = exp(1j*2*pi*fc*n/Fs);

    % Modulação em anel
    y_complex = y .* c;

    % Parte real = sinal "robotizado"
    yrob = real(y_complex);

    % Normalização simples para evitar clipping
    maxval = max(abs(yrob));
    if maxval > 0
        yrob = 0.99 * yrob / maxval;
    end
end
