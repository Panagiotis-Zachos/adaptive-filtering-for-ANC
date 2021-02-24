%% Active Noise Cancellation Sim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars; clc;

fs = 44100;
[headphone_ir, ~] = audioread('HpCF_AKG_K141_MKII_A.wav');
headphone_ir = headphone_ir(1:128);

[n1, ~] = audioread('City Sound in New York - SOUND TRAVELER SERIES.wav');

[n2, ~] = audioread('party-crowd-daniel_simon.wav');
n = (n1+n2)';

clear n1 n2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Headphone Enclosure LPF approximation
% IIR Filter Order: 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HEnc = headphone_enclosure_IR();     % Filter Impulse Response

figure; freqz(HEnc); 
title('Headphone Enclosure LPF Approximation Frequency Response');
figure; plot(HEnc); 
title('Headphone Enclosure Impulse Response Approximation');

clear Fpass Fstop Apass Astop match h Hd imp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Headphone Enclosure Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Approximation Filter
b2 = fir1(100,0.15, 'low');
HEncEst = filter(b2,1,HEnc);    

% figure; plot(HEnc); hold on; 
% plot(HEncEst); hold off; 
% title('Original vs. Estimated Headphone Enclosure');
% legend('Original', 'Estimated');
% [Xa, Ya] = alignsignals(HEnc, HEncEst, [], 'truncate');
% figure; plot(Xa); hold on; 
% plot(Ya); hold off; 
% title('Original vs. Estimated Headphone Enclosure - Aligned');
% legend('Original', 'Estimated');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Audible Signal part
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

music = audioread('Rory Gallagher - Shadow Play.wav');
musicH = conv(music, headphone_ir,'same');

NoiseAfterEnclosure = conv(n,HEnc,'same');
NoiseAfterEnclosure = NoiseAfterEnclosure(1:length(musicH))';

noisyMusic = musicH + NoiseAfterEnclosure;
snr = snr(noisyMusic,n')

t = 0:1/fs:10;
figure;
subplot(2,1,1); plot(t(1:5000),musicH(1:5000)); xlim([0, 0.1134]);
xlabel('Time(s)')
title('Original Music Signal (Convolved With HeadPhone IR)');
subplot(2,1,2); plot(t(1:5000),noisyMusic(1:5000)); xlim([0, 0.1134]);
xlabel('Time(s)')
title('Music Signal with Added Noise');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% De-Noising Procedure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EstimatedNoise = conv(n, HEncEst, 'same')';

[noisyA, EstimatedNA] = alignsignals(noisyMusic, EstimatedNoise, [], 'truncate');
EstimatedNA = EstimatedNA(1:length(noisyA));
deNoised = noisyA - EstimatedNA;

figure; 
subplot(3,1,1); plot(t',noisyMusic); ylim([-1 1]);
title('Noisy Music Signal');
subplot(3,1,2); plot(t',deNoised); ylim([-1 1]);
title('De-Noised Music Signal');
subplot(3,1,3); plot(t', musicH); ylim([-1 1]);
title('Original Music Signal');

immse = immse(deNoised, musicH)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Adaptive FIR Filter without Noise Knowledge
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars; clc;

fs = 44100;
[headphone_ir, ~] = audioread('HpCF_AKG_K141_MKII_A.wav');
headphone_ir = headphone_ir(1:256);

music = audioread('Rory Gallagher - Shadow Play.wav');
musicH = conv(music, headphone_ir,'same');

HEnc = headphone_enclosure_IR();     % Filter Impulse Response

[n1, ~] = audioread('City Sound in New York - SOUND TRAVELER SERIES.wav');

[n2, ~] = audioread('party-crowd-daniel_simon.wav');
n = 0.3 *(n1+n2)';

HEnc = HEnc(1:256);
NoiseAfterEnclosure = conv(n,HEnc,'same');
NoiseAfterEnclosure = NoiseAfterEnclosure(1:length(musicH))';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LMS Filter Calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = musicH;

h = headphone_ir;

ch_delay = fix(length(h)/2);        % Channel delay = 2
eq_length = 100;                     % Length of adaptive equalizer
eq_delay = fix(eq_length/2);        % Delay of channel equalizer
total_delay = ch_delay + eq_delay;  % Total delay

out = conv(s,h,'same');             % Channel output signal

un = s + NoiseAfterEnclosure;     % Input to adaptive filter

dn = [zeros(1,total_delay) music(1:length(un)-total_delay)'];
% Desired signal
w0 = zeros(eq_length,1);            % Initialize filter coefs to 0
% LMS algorithm
mulms = 0.01;                       % Step size

Slms = LMSinit(w0,mulms); % Initialization
% Perform LMS algorithm
[ylms,~,~] = LMSadapt(un,dn,Slms);

figure;
subplot(3,1,1); plot(music); 
title('Original Signal');
subplot(3,1,2); plot(ylms ./ max(abs(ylms)));
title('Filter Output');
subplot(3,1,3); plot(un); ylim([-1 1]);
title('Noisy Signal');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Adaptive FIR Filter WITH Noise Knowledge
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars; clc;

fs = 44100;
[headphone_ir, ~] = audioread('HpCF_AKG_K141_MKII_A.wav');
headphone_ir = headphone_ir(1:256);

music = audioread('Rory Gallagher - Shadow Play.wav');
musicH = conv(music, headphone_ir,'same');

HEnc = headphone_enclosure_IR();     % Filter Impulse Response

[n1, ~] = audioread('City Sound in New York - SOUND TRAVELER SERIES.wav');

[n2, ~] = audioread('party-crowd-daniel_simon.wav');

n = 0.3 *(n1+n2)';

HEnc = HEnc(1:256);
NoiseAfterEnclosure = conv(n,HEnc,'same');
NoiseAfterEnclosure = NoiseAfterEnclosure(1:length(musicH))';

noisyMusic = musicH + NoiseAfterEnclosure;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LMS Filter Calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = HEnc;

ch_delay = fix(length(h)/2);        % Channel delay = 2
eq_length = 31;                    % Length of adaptive equalizer
eq_delay = fix(eq_length/2);        % Delay of channel equalizer
total_delay = ch_delay + eq_delay;  % Total delay


un = n;     % Input to adaptive filter

dn = [zeros(1,total_delay) NoiseAfterEnclosure(1:length(un)-total_delay)'];
% Desired signal
w0 = zeros(eq_length,1);            % Initialize filter coefs to 0
% LMS algorithm
mulms = 0.01;                     % Step size

Slms = LMSinit(w0,mulms); % Initialization
% Perform LMS algorithm
[ylms,enlms,Slms] = LMSadapt(un,dn,Slms);

deNoised = noisyMusic - ylms';

figure;
subplot(3,1,1); plot(musicH); ylim([-1 1]);
title('Original Signal');
subplot(3,1,2); plot(deNoised); ylim([-1 1]);
title('De Noised Signal');
subplot(3,1,3); plot(noisyMusic); ylim([-1 1]);
title('Noisy Signal');

figure;
plot(dn); hold on;
plot(ylms);
plot(enlms);
hold off;
legend('Reference','Estimated','Error');
