function [ HEnc ] = headphone_enclosure_IR()
% Headphone Enclosure LPF approximation
% IIR Filter Order: 6
fs = 44100;
Fpass = 4410;    % Passband Frequency
Fstop = 6000;    % Stopband Frequency
Apass = 1;       % Passband Ripple (dB)
Astop = 60;      % Stopband Attenuation (dB)
match = 'both';  % Band to match exactly

h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, fs);
Hd = design(h, 'ellip', 'MatchExactly', match);
imp = zeros(1,512);
imp(1) = 1;
HEnc = filter(Hd, imp);     % Filter Impulse Response

end

