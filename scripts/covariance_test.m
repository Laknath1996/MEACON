%Covariance
close all; clc; 
X=round(rand(100,1)); 
Y=round(rand(100,1));
plot(X, 'X'); 
hold on; 
plot(Y,'X');

[c, lags] = xcov(X,Y, 10);

figure;
plot(lags,c)

% figure; 
% plot(X, Y, 'X')