%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VOCODEUR : Programme principal réalisant un vocodeur de phase 
% et permettant de :
%
% 1- modifier le tempo (la vitesse de "prononciation")
%    sans modifier le pitch
%
% 2- modifier le pitch 
%    sans modifier la vitesse 
%
% 3- "robotiser" une voix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all; clc;

%% Récupération d'un signal audio
%--------------------------------
[filename, pathname] = uigetfile('*.wav', 'Choisissez un fichier audio');
if isequal(filename,0)
    error('Aucun fichier audio sélectionné.');
end

file = fullfile(pathname, filename);
[y, Fs] = audioread(file);
y = y(:,1);   % mono

% Observation du signal original
N = length(y);
t = (0:N-1)/Fs;
f = (0:N-1)*Fs/N; f = f - Fs/2;

figure(1)
subplot(3,1,1), plot(t,y)
title('Signal original')
xlabel('Temps (s)')
subplot(3,1,2), plot(f, abs(fftshift(fft(y))))
title('Spectre du signal original')
xlabel('Fréquence (Hz)')
myspectrogram(y,128,120,128,Fs)
title('Spectrogramme du signal original')

disp('------------------------------------');
disp('SON ORIGINAL');
soundsc(y,Fs);

%% MENU PRINCIPAL
%--------------------------------
continuer = true;
3

while continuer
    disp(' ');
    disp('====================================');
    disp('            MENU VOCODEUR           ');
    disp('====================================');
    disp('1) Modifier la vitesse (tempo) sans modifier le pitch');
    disp('2) Modifier le pitch sans modifier la vitesse');
    disp('3) Robotiser la voix');
    disp('4) Quitter');
    choix = input('Votre choix : ');
    
    switch choix
        
        %% 1- MODIFICATION DE LA VITESSE (TEMPO)
        case 1
            disp('------------------------------------');
            disp('1- MODIFICATION DE LA VITESSE SANS MODIFIER LE PITCH');
            
            Nfft  = 1024;
            Nwind = Nfft;
            
            % rapp = v_orig / v_arrivee
            % -> rapp_lent > 1  : son plus lent
            % -> rapp_rapide < 1: son plus rapide
            
            % Plus lent
            rapp_lent = 3/2;
            ylent = PVoc(y, rapp_lent, Nfft, Nwind);
            pause;
            disp('Son plus lent (pitch conservé)');
            soundsc(ylent, Fs);
            
            % Plus rapide
            rapp_rapide = 2/3;
            yrapide = PVoc(y, rapp_rapide, Nfft, Nwind);
            pause;
            disp('Son plus rapide (pitch conservé)');
            soundsc(yrapide, Fs);
        
        %% 2- MODIFICATION DU PITCH SANS CHANGER LA VITESSE
        case 2
            disp('------------------------------------');
            disp('2- MODIFICATION DU PITCH SANS MODIFIER LA VITESSE');
            
            Nfft  = 256;
            Nwind = Nfft;
            
            % 2.1 - Pitch plus aigu
            a = 2; 
            b = 3;
            % Même schéma que dans le Vocodeur.txt original
            yvoc    = PVoc(y, a/b, Nfft, Nwind);
            ypitch1 = resample(yvoc, a, b);  % garde la même vitesse
            pause;
            disp('Pitch augmenté (vitesse conservée)');
            soundsc(ypitch1, Fs);
            
            % 2.2 - Pitch plus grave
            a = 3; 
            b = 2;
            yvoc    = PVoc(y, a/b, Nfft, Nwind);
            ypitch2 = resample(yvoc, a, b);
            pause;
            disp('Pitch diminué (vitesse conservée)');
            soundsc(ypitch2, Fs);
        
        %% 3- VOIX ROBOTISÉE (MENU COM AS FREQUÊNCIAS 1 A 1)
        case 3
            continuerRob = true;
            while continuerRob
                clc;
                disp('------------------------------------');
                disp('      ROBOTISATION DE LA VOIX       ');
                disp('------------------------------------');
                disp('Choisissez la fréquence de la porteuse fc (Hz) :');
                disp(' 1) 200 Hz');
                disp(' 2) 500 Hz');
                disp(' 3) 1000 Hz');
                disp(' 4) 2000 Hz');
                disp(' 5) Autre fréquence...');
                disp(' 6) Retour au menu principal');
                op = input('Option : ');
                
                switch op
                    case 1
                        Fc = 200;
                    case 2
                        Fc = 500;
                    case 3
                        Fc = 1000;
                    case 4
                        Fc = 2000;
                    case 5
                        Fc = input('Entrez la fréquence désirée (Hz) : ');
                    case 6
                        break;
                    otherwise
                        disp('Option invalide, essayez encore.');
                        pause(1);
                        continue;
                end
                
                if op == 6
                    break;
                end
                
                % Chamada da função de voz robotizada
                yrob = Rob(y, Fc, Fs);
                disp('------------------------------------');
                fprintf('3- SON "ROBOTISÉ" (fc = %.1f Hz)\n', Fc);
                soundsc(yrob, Fs);
                
                % Observação (opcional, igual ao esqueleto original)
                Nrob = length(yrob);
                trob = (0:Nrob-1)/Fs;
                frob = (0:Nrob-1)*Fs/Nrob; frob = frob - Fs/2;
                
                figure(6)
                subplot(3,1,1), plot(trob,yrob)
                title(sprintf('Signal "robotisé" (fc = %.1f Hz)', Fc))
                xlabel('Temps (s)')
                subplot(3,1,2), plot(frob, abs(fftshift(fft(yrob))))
                title('Spectre du signal "robotisé"')
                xlabel('Fréquence (Hz)')
                subplot(3,1,3), spectrogram(yrob,128,120,128,Fs,'yaxis')
                title('Spectrogramme du signal "robotisé"')
                
                resp = input('Tester une autre fréquence ? (o/n) : ', 's');
                if lower(resp) ~= 'o' && lower(resp) ~= 's'
                    continuerRob = false;
                end
            end
        
        %% 4- QUITTER
        case 4
            continuer = false;
            disp('Fin du programme VOCODEUR.');
        
        otherwise
            disp('Choix invalide. Veuillez recommencer.');
    end
end
