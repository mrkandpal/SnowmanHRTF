function [out, delay] = head_itd(in, theta, a, fs, frac)
%delay assocuated with head shadow

c = 343;

ac = a/c;

if abs(theta) < pi/2
    delay = -ac*cos(theta)+ac; % adding ac to the result in order to have positive delays and keep the system causal, the ITD stays the same.
else
    delay = ac*(abs(theta)-pi/2)+ac;
end

% convert time-delays to samples
delay_samp = delay*fs;

if frac
    % fractional delay 
    base_delay = floor(delay_samp);
    frac_delay = delay_samp - base_delay;
    h = dfilt.delay(base_delay);
    d = fdesign.fracdelay(frac_delay);
    ThirdOrderFrac = design(d,'lagrange','filterstructure','farrowfd');
    Hcas = dfilt.cascade(h, ThirdOrderFrac);
    out = filter(Hcas, in);
else
    % delay filter with rounding the delay to closest integer
    h = dfilt.delay(round(delay_samp));
    out = filter(h, in);
end


end

