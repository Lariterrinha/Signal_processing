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
[filename, pathname] = uigetfile('*.wav', 'Choose an audio file');
if isequal(filename,0)
    error('No audio file selected.');
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
title('Original signal')
xlabel('Time (s)')
subplot(3,1,2), plot(f, abs(fftshift(fft(y))))
title('Spectrum of the original signal')
xlabel('Frequency (Hz)')

% se não tiver myspectrogram.m, use spectrogram
spectrogram(y,128,120,128,Fs,'yaxis')
title('Spectrogram of the original signal')

disp('------------------------------------');
disp('ORIGINAL SOUND');
soundsc(y,Fs);

%% MAIN MENU
%--------------------------------
continuer = true;

while continuer
    disp(' ');
    disp('====================================');
    disp('              VOCODER MENU          ');
    disp('====================================');
    disp('1) Change speed (tempo) without changing pitch');
    disp('2) Change pitch without changing speed');
    disp('3) Robotize the voice');
    disp('4) Harmonic Duo/Trio');
    disp('5) Whisper / Ghost Voice');
    disp('6) Telephone / Radio Effect');
    disp('7) Exit');
    choix = input('Your choice: ');
    
    switch choix
        
        %% 1- MODIFICATION DE LA VITESSE (TEMPO)
        case 1
            disp('------------------------------------');
            disp('1- CHANGE SPEED (TEMPO) WITHOUT CHANGING PITCH');
            
            Nfft  = 1024;
            Nwind = Nfft;
            
            % rapp = v_orig / v_arrivee
            % -> rapp_lent > 1  : son plus lent
            % -> rapp_rapide < 1: son plus rapide
            
            % Plus lent
            rapp_lent = 3/2;
            ylent = PVoc(y, rapp_lent, Nfft, Nwind);
            pause;
            disp('Slower sound (pitch preserved)');
            soundsc(ylent, Fs);
            
            % Plus rapide
            rapp_rapide = 2/3;
            yrapide = PVoc(y, rapp_rapide, Nfft, Nwind);
            pause;
            disp('Faster sound (pitch preserved)');
            soundsc(yrapide, Fs);
        
        %% 2- MODIFICATION DU PITCH SANS CHANGER LA VITESSE
        case 2
            disp('------------------------------------');
            disp('2- CHANGE PITCH WITHOUT CHANGING SPEED');
            
            Nfft  = 256;
            Nwind = Nfft;
            
            % 2.1 - Pitch plus aigu
            a = 2; 
            b = 3;
            yvoc    = PVoc(y, a/b, Nfft, Nwind);
            ypitch1 = resample(yvoc, a, b);  % precisa da Signal Processing Toolbox
            pause;
            disp('Increased pitch (speed preserved)');
            soundsc(ypitch1, Fs);
            
            % 2.2 - Pitch plus grave
            a = 3; 
            b = 2;
            yvoc    = PVoc(y, a/b, Nfft, Nwind);
            ypitch2 = resample(yvoc, a, b);
            pause;
            disp('Decreased pitch (speed preserved)');
            soundsc(ypitch2, Fs);
        
        %% 3- VOIX ROBOTISÉE (MENU COM AS FREQUÊNCIAS 1 A 1)
        case 3
            continuerRob = true;
            while continuerRob
                clc;
                disp('------------------------------------');
                disp('         VOICE ROBOTIZATION         ');
                disp('------------------------------------');
                disp('Choose the carrier frequency fc (Hz):');
                disp(' 1) 200 Hz');
                disp(' 2) 500 Hz');
                disp(' 3) 1000 Hz');
                disp(' 4) 2000 Hz');
                disp(' 5) Other frequency...');
                disp(' 6) Back to main menu');
                op = input('Option: ');
                
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
                        Fc = input('Enter desired frequency (Hz): ');
                    case 6
                        break;
                    otherwise
                        disp('Invalid option, please try again.');
                        pause(1);
                        continue;
                end
                
                if op == 6
                    break;
                end
                
                % Chamada da função de voz robotizada
                yrob = Rob(y, Fc, Fs);
                disp('------------------------------------');
                fprintf('3- ROBOT VOICE (fc = %.1f Hz)\n', Fc);
                soundsc(yrob, Fs);
                
                % Observação (opcional)
                Nrob = length(yrob);
                trob = (0:Nrob-1)/Fs;
                frob = (0:Nrob-1)*Fs/Nrob; frob = frob - Fs/2;
                
                figure(6)
                subplot(3,1,1), plot(trob,yrob)
                title(sprintf('Robot signal (fc = %.1f Hz)', Fc))
                xlabel('Time (s)')
                subplot(3,1,2), plot(frob, abs(fftshift(fft(yrob))))
                title('Spectrum of the robot signal')
                xlabel('Frequency (Hz)')
                subplot(3,1,3), spectrogram(yrob,128,120,128,Fs,'yaxis')
                title('Spectrogram of the robot signal')
                
                resp = input('Test another frequency? (y/n): ', 's');
                if lower(resp) ~= 'y'
                    continuerRob = false;
                end
            end
        
        %% 4- HARMONIC DUO / TRIO
        case 4
            disp('------------------------------------');
            disp('4- HARMONIC DUO / TRIO (PITCH SHIFTING)');
            
            y_trio = HarmonicDuoTrio(y, Fs);
            soundsc(y_trio, Fs);

        
        %% 5- WHISPER / GHOST VOICE
        case 5
            disp('------------------------------------');
            disp('5- WHISPER / GHOST VOICE (WHISPERIZATION)');
            
            y_whisper = WhisperGhostVoice(y, Fs);
            soundsc(y_whisper, Fs);

        
        %% 6- TELEPHONE / RADIO EFFECT
        case 6
            disp('------------------------------------');
            disp('6- TELEPHONE / RADIO EFFECT');

            y_radio = TelephoneRadioEffect(y, Fs);
            soundsc(y_radio, Fs);
        
        %% 7- EXIT
        case 7
            continuer = false;
            disp('Exiting VOCODER program.');
        
        otherwise
            disp('Invalid choice. Please try again.');
    end
end
