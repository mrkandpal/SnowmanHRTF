clear

%Input audio/music
%audioIn = audioread('audio.wav');

%Input a Delta Signal to HAT Model
in = [1; zeros(199,1)];

% constants
frac = 1; % fractional delay flag
fs = 48000;
c = 343; % speed of sound

%Brown-Duda Paper constants
alfa_min = 0.1; % shadow cst
theta_min = 5*pi/6; % shadow cst (=150 degree)
theta_flat = theta_min*(0.5+1/pi*asin(alfa_min/(2-alfa_min))); %

% anthropometric constants
a = 0.0775; % head radius in [m]
b = 0.169; % torso radius
h = 0.053; % neck length

%reflection Coefficient
rho = 0.3; 

e_b = 0.0094; % ear front shift // ear displacement according to `ITD Paper
e_d = 0.021; % ear down shift
[D_l(1), D_l(2), D_l(3)] = sph2cart(atan(a/e_b), atan(a/e_d) - pi/2, a); % left ear position
[D_r(1), D_r(2), D_r(3)] = sph2cart(-atan(a/e_b), atan(a/e_d) - pi/2, a); % right ear position

torsoFrontShift = 0;
torsoOffset = a + b + h;
%Left observation point on torso
[leftTorso(1), leftTorso(2), leftTorso(3)] = sph2cart(atan(b/torsoFrontShift), atan(b/torsoOffset) - pi/2, torsoOffset);
%Right observation point on torso
[rightTorso(1), rightTorso(2), rightTorso(3)] = sph2cart(-atan(b/torsoFrontShift), atan(b/torsoOffset) - pi/2, torsoOffset);
%Torso Center
B = (leftTorso + rightTorso)/2;

elevations = 240:1:270;

for i=1:size(elevations,2)
    %%source locations in azimuth and elevation
    az = 90;
    el = elevations(i);
    M = [0, 0, 0]; % center of head point
    az_rad = deg2rad(az); % we are in the vertical-polar coordinate system
    el_rad = deg2rad(el);
    [x, y, z] = sph2cart(-az_rad, el_rad, 1);
    x(abs(x) < eps) = 0;
    y(abs(y) < eps) = 0;
    z(abs(z) < eps) = 0;
    S = [x, y, z]; % source point 

    % vectors needed for snowman
    d_l = D_l - B; % vectors from torso center to ears
    d_r = D_r - B;
    d_l_norm = norm(d_l); % vector norms
    d_r_norm = norm(d_r);
    s = (S - B)/norm(S-B);

    % torso-shadow cone limit from left and right ear
    shadow_limit_l = -sqrt(d_l_norm^2 - b^2);
    shadow_limit_r = -sqrt(d_l_norm^2 - b^2);


    % left ear
    ds_dot_l = dot(d_l,s);
    if ds_dot_l < shadow_limit_l
       outL = torsoShadowSub(in, M, D_l, s, d_l, a, b, alfa_min, theta_min, theta_flat, fs, frac);
    else
       outL = torsoReflexionSub(in, M, D_l, s, d_l, a, b, c, rho, alfa_min, theta_min, fs, frac);
    end

    % right ear
    ds_dot_r = dot(d_r,s);
    if ds_dot_r < shadow_limit_r
       outR = torsoShadowSub(in, M, D_r, s, d_r, a, b, alfa_min, theta_min, theta_flat, fs, frac);
    else
       outR = torsoReflexionSub(in, M, D_r, s, d_r, a, b, c, rho, alfa_min, theta_min, fs, frac);
    end
    
    rights(i,:) = outR; 
    
    %Plot Frequency response
    [H,F] = freqz(outR,1,256,fs);
    semilogx(F,mag2db(abs(H)) + 1 * (i-1)); grid on; hold on;
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
end

%Plot Impulse Responses in 3-D
% mesh(rights);
% xlabel('ms')
% ylabel('Elevation')

%Listen to audio
%%Resample audio to 48 KHz
% audioIn = resample(audioIn, 48000, fs)
% output(:,1) = convolveFFT(audioIn, outL);
% output(:,2) = convolveFFT(audioIn, outR);
% output = output/max(abs(output(:)));
% soundsc(output, fs)















