function out = head_shadow(in, theta, a, alfa_min, theta_min, fs)
%head shadowing filter

c = 343;
T = 1/fs;

alfa = (1+alfa_min/2) + (1-alfa_min/2)*cos(theta/theta_min*pi);
% theta_flat = theta_min*(0.5+1/pi*asin(alfa_min/(2-alfa_min))); % in rad
tau = 2*a/c;

% shadow filter
b_coeff = [2*alfa*tau+T, T-2*alfa*tau];
a_coeff = [2*tau+T, T-2*tau];

out = filter(b_coeff, a_coeff, in);

end

