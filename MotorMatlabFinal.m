load_motor_data;

%loads and plots the motor calibration data
function [t, y_L, v_L, y_R, v_R] = load_motor_data()
%path and file name of data
fpath = '/Users/sbloomuel/Downloads/'; %path (change this!)
fname_in = 'CoolTerm Test.txt'; %file name (change this!)
%load the motor calibration data
motor_data = importdata([fpath,fname_in]);
%unpack the motor calibration data
t = motor_data(:,1);
y_L = motor_data(:,2); v_L = motor_data(:,3);
y_R = motor_data(:,4); v_R = motor_data(:,5);
%plot the motor calibration data
figure(1);
subplot(2,1,1);
hold on
plot(t,v_L,'k','linewidth',1);
plot(t,v_R,'r','linewidth',1);
xlabel('time (sec)'); ylabel('wheel speed (m/sec)');
title('Motor Calibration Data');
h1 = legend('Left Wheel','Right Wheel');
set(h1,'location','southeast');
subplot(2,1,2);
hold on
plot(t,y_L,'k','linewidth',1);
plot(t,y_R,'r--','linewidth',1);
xlabel('time (sec)'); ylabel('wheel command (-)');
title('Motor Calibration Data');
h2 = legend('Left Wheel','Right Wheel');
set(h2,'location','southeast');
end
% Load data
data_struct = readmatrix('CoolTerm Test.txt');
t = data_struct(:, 1); 
t = t - t(1);
YL = data_struct(:, 2);
vL = data_struct(:, 3);
YR = data_struct(:, 4);
vR = data_struct(:, 5);
ft = fittype('c*(1 - exp(-a*t))', 'independent', 't');

f_params = fit(t, vR, ft);

% parameters of fit
c = f_params.c;
a = f_params.a

tFit = linspace(min(t), max(t), 1000);

figure;
hold on;
plot(t, vR, 'b*', 'MarkerSize', 4, 'DisplayName', 'Measured');
plot(tFit, c*(1 - exp(-a*tFit)), 'r-', 'LineWidth', 2, 'DisplayName', 'Fit');
xlabel('Time (seconds)');
ylabel('Velocity (m/s)');
title('Left Motor Step Response Fit');
legend('location', 'southeast');
YL = mean(YL);
b_left = c / YL
tau_left = 1 / a
ft = fittype('c*(1 - exp(-a*t))', 'independent', 't');

f_params = fit(t, vL, ft);

% parameters of fit
c = f_params.c;
a = f_params.a

tFit = linspace(min(t), max(t), 1000);

figure;
hold on;
plot(t, vL, 'b*', 'MarkerSize', 4, 'DisplayName', 'Measured');
plot(tFit, c*(1 - exp(-a*tFit)), 'r-', 'LineWidth', 2, 'DisplayName', 'Fit');
xlabel('Time (seconds)');
ylabel('Velocity (m/s)');
title('Right Motor Step Response Fit');
legend('location', 'southeast');
YR = mean(YR);
b_right = c / YR
tau_right = 1 / a

function [t, theta] = load_pendulum_data()
    %path and file name of data
    fpath = '/Users/sbloomuel/Downloads/'; %path (change this!)
    fname_in = 'Gyro Test.txt'; %file name (change this!)
    %load the pendulum calibration data
    pendulum_data = importdata([fpath,fname_in]);
    %unpack the pendulum calibration dat
    t = pendulum_data(:,1); theta = pendulum_data(:,2);
    %plot the motor calibration data
    figure();
    hold on
    plot(t,theta,'k','linewidth',1);
    xlabel('time (sec)'); ylabel('angle (rad)');
    title('Pendulum Calibration Data');
end

% should get around 4 rad/s -- thanks felix.
function [omega_n, leff] = find_peaks()
    [t, theta] = load_pendulum_data();
    [pks, locs] = findpeaks(theta, t, 'MinPeakDistance', 0.8, 'MinPeakHeight', 0);
    figure()
    hold on
    plot(t, theta, 'k')
    plot(locs, pks, 'go')
    peak_intervals = diff(locs);
    mean_period = mean(peak_intervals);
    omega_n = 2*pi / mean_period;
    leff = (9.81 / omega_n^2);
    disp("omega n: "); disp(omega_n);
    disp('leff: '); disp(leff); % about 1.5 feet long.
end

[omega_n, leff] = find_peaks()

% finding leff
% Calculate the effective length of the pendulum using the natural frequency
k_p = ((leff) / (a * b)) * (((a^2)/3) + (omega_n^2))
k_i = ((leff) / (a * b)) * (((a^3)/27) + (a * omega_n^2))
