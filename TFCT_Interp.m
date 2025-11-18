function Y = TFCT_Interp(X, t, Nov)
% y = TFCT_Interp(X, t, Nov)   
% Interpolation du vecteur issu de la TFCT
%
% X : matrice issue de la TFCT (lignes = bins de fréquence, colonnes = trames)
% t : vecteur des "temps" (valeurs réelles) sur lesquels on interpole
% Nov : hop d'analyse (gardé pour compatibilité, pas utilisé explicitement)
%
% Pour chaque valeur de t, on interpole le MODULE du spectre 
% et on préserve le saut de phase entre 2 colonnes successives de X.

    [nBins, nCols] = size(X);
    Y = zeros(nBins, length(t));

    for k = 1:length(t)
        tk = t(k);

        % Limitar t no intervalo válido [0, nCols-1)
        if tk < 0
            tk = 0;
        end
        if tk > (nCols-1-1e-6)
            tk = nCols-1-1e-6;
        end

        base = floor(tk);       % índice inteiro da coluna base
        frac = tk - base;       % parte fracionária entre 0 e 1

        if base >= (nCols-1)
            base = nCols-2;
            frac = 1;
        end

        col1 = base + 1;        % em MATLAB, colunas começam em 1
        col2 = col1 + 1;

        X1 = X(:, col1);
        X2 = X(:, col2);

        % --- Interpolação do módulo ---
        mag1 = abs(X1);
        mag2 = abs(X2);
        mag  = (1-frac).*mag1 + frac.*mag2;

        % --- Interpolação de fase com unwrap local ---
        phi1 = angle(X1);
        phi2 = angle(X2);
        dphi = phi2 - phi1;

        % unwrap da diferença de fase para [-pi, pi)
        dphi = dphi - 2*pi*round(dphi/(2*pi));

        % fase interpolada
        phi  = phi1 + frac .* dphi;

        % coluna interpolada
        Y(:, k) = mag .* exp(1j*phi);
    end
end
