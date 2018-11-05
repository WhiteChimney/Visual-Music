% This code helps to see the real-time freq space using fft.
clear
clear sound


%% WARNING! Do not run this program at midnight!


%% Read in audio file and preset parameters
directory = 'C:\Users\sound_project\';
filename = 'Ennio Morricone - The Crave.mp3';

DispMode = 1;                           % 0: display choosed channel (chn0)
                                        % 1: display all channels in a same plot
                                        % 2: display differenct channels seperately
chn0 = 1;                               % choose the channel of the music
Fs1 = 44.1e3;                           % resampling freq
Spd = 1.00;                             % playing speed
Tr = 0.03;          % Approx refresh time interval (when music is playing 
                    % in normal speed), will be adjusted due to 
                    % consideration of the efficiency of FFT algorithm.
                    % If your pic keeps falling behind your sound, 
                    % please increase this parameter.
FreqRange = [0 1e4];                    % Frequency range
AmpRange = [0 200];                     % Amplitude range
T_delay = 0.00;                         % delay the pic to sync, >=0


%% FFT of each segment of the sample music
[Msc0, Fs0] = audioread([directory, filename]);     % read audio file
if DispMode == 0                                    % resampling
    Msc1 = resample(Msc0(:,chn0), Fs1, Fs0);
elseif DispMode == 0 || DispMode == 1
    Msc1 = resample(Msc0, Fs1, Fs0);
else
    disp('Choose the right Display Mode!');
    return;
end
[N, chns] = size(Msc1);                 % number of sampling points
dt = 1/Fs1;                             % time interval
Lpc = 2^nextpow2(Tr*Fs1);               % length of each piece of music
Nf = Lpc/2 + 1;                         % number of points in freq domain
f = (0:Nf-1) * Fs1/Lpc;                 % real freq needs a coef of fs/N

Freq = zeros(Nf,chns);
if DispMode == 0 || DispMode == 1
    p = semilogx(f,Freq);       % plot amp-freq with logarithmic x-axis
    xlim(FreqRange);                    % set freq range
    ylim(AmpRange);                     % set amp range
    title(filename);                    % title and labels of the pic
    legend_list = repmat('Channel',chns,1);
    legend_list = strcat(legend_list,string((1:chns).'));
    legend(legend_list);
    xlabel('Frequency/Hz');
    ylabel('Relative Amplitude');
else
    for i = 1:chns
        subplot(chns,1,i);
        eval(['p',num2str(i),'=semilogx(f,Freq(:,i));']);
                          % plot amp-freq with logarithmic x-axis
        xlim(FreqRange);                    % set freq range
        ylim(AmpRange);                     % set amp range
        title(['Channel',num2str(i)]);      % title and labels of the pic
        xlabel('Frequency/Hz');
        ylabel('Relative Amplitude');
    end
    suptitle(filename);
end    

% Start the loop
Pt = 0;                                 % playing progress pointer
while Pt < N                            % while the song is not over
    Pt = Pt + Lpc;                      % move to the next segment
    if Pt > N
        break                           % exit loop when the music is over
    end
    
    % FFT of music pieces
    MscPc = Msc1(Pt-Lpc+1:Pt,:);        % the present piece of music
    Freq = fft(MscPc);                  % FFT of the piece of music
    Freq = abs(Freq(1:Lpc/2+1,:));      % real amp is abs(fft(x)) * dt

    % Sync of pic and sound
    if Pt == Lpc                        % the first piece of music
        sound(Msc0, Spd*Fs0);           % begin playing music
        pause(T_delay);                 % pause for the sound to start
        T0 = clock;                     % start time of the music
        T0 = 3600*T0(4) + 60*T0(5) + T0(6);
        T1 = T0;                        % time of next refreshing
    end
    while T1 < T0 + Lpc/Fs1/Spd         % pause refreshing the pic 
        T1 = clock;                     % until the next piece of music
        T1 = 3600*T1(4) + 60*T1(5) + T1(6);
    end
    T0 = T0 + Lpc/Fs1/Spd;
    
    % update data points
    if DispMode == 0 || DispMode == 1
        set(p, {'YData'}, num2cell(Freq.',2) )
    else
        for i = 1:chns
            eval(['set(p',num2str(i),', "YData", Freq(:,i));']);
        end
    end
    drawnow;
end
