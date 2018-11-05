% This is a project to see the sound waves using fft.
% Display in bar plot version. 
clear sound
clear


%% WARNING! Do not run this program at midnight! 


%% Read in audio file and preset parameters
directory = 'C:\Users\79082\MATLAB Drive\Signals and Systems\sound_project\';
filename = 'Ennio Morricone - The Crave.mp3';
% filename = 'Steve¡¤Feng - Flying Bug (Piano Version).flac';
% filename = 'Megalovania (Piano Version).flac';
% filename = 'Jeno Jando - 12 Variations in C Major on Ah vous dirai-je, maman, K. 265.flac';
% filename = 'Arthur Rubinstein - Op. 27 - Sonata No. 14 - Moonlight - 3 Presto agitato.mp3';
% filename = 'Lang Project - The Crave (Piano Version) [From The Legend of 1900].flac';
% filename = 'Adam Levine - Lost Stars.flac';

chn = 1;                                % choose the channel of the music
Fs1 = 44.1e3;                           % sampling freq, 44.1kHz by default

Tr = 0.10;          % Approx refresh time interval, will be adjusted due to 
                    % consideration of the efficiency of FFT algorithm
                    % If your pic keeps falling behind your sound, 
                    % please increase this parameter.

Nb = 30;                                % number of blocks
FreqRange = [1 5];                      % Frequency range
AmpRange = [0 50];                      % Amplitude range
T_delay = 0;                            % delay the pic to sync, >=0


%% FFT of each segment of the sample music
[Msc0, Fs0] = audioread([directory, filename]);  % read audio file
Msc1 = resample(Msc0(:,chn), Fs1, Fs0); % resampling
N = length(Msc1);                       % number of sampling points
dt = 1/Fs1;                             % time interval
Lpc = 2^nextpow2(Tr*Fs1);               % length of each piece of music
Nf = Lpc/2 + 1;                         % number of points in freq domain
f = (0:Nf-1) * Fs1/Lpc;                 % real freq needs a coef of fs/N
f_log = 10.^linspace(0,log10(Fs1),Nb+1);% take the log of freq axis
f_ct = log10(f_log(1:end-1));           % set centers of the bars

% Start the loop
Pt = 0;                                 % music location pointer
while Pt < N                            % while the song is not over
    Pt = Pt + Lpc;                      % move to the next segment
    if Pt > N
        break                           % exit loop when the music is over
    end
    
    % FFT of music pieces
    MscPc = Msc1(Pt-Lpc+1:Pt);          % the present piece of music
    Freq = fft(MscPc);                  % FFT of the piece of music
    Freq = abs(Freq(1:Lpc/2+1)) * dt;   % real amp is abs(fft(x)) * dt
    Amp = zeros(1,Nb);                  % relative amp of each bar is the
    for i = 1:Nb                        % sum of amps in each section
        Amp(i) = sum(Freq(f>=f_log(i) & f<f_log(i+1)));
    end
    bar(f_ct, 1e3 * Amp);               % plot in bar chart
    xlim(FreqRange);                    % set freq range
    ylim(AmpRange);                     % set amp range
    title(filename);                    % title of the pic
    xlabel('Frequency');
    ylabel('Relative Amplitude');
    
    % Sync of pic and sound
    if Pt == Lpc                        % the first piece of music
        sound(Msc0,Fs0);                % begin playing music
        pause(T_delay);                 % pause for the sound to start
        T0 = clock;                     % start time of the music
        T0 = 3600*T0(4) + 60*T0(5) + T0(6);
        T1 = T0;                        % time of next refreshing
    end
    while T1 < T0 + Lpc/Fs1             % pause refreshing the pic 
        T1 = clock;                     % until the next piece of music
        T1 = 3600*T1(4) + 60*T1(5) + T1(6);
    end
    T0 = T1;
    
    % draw the plot
    drawnow;
end
