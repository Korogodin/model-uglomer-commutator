function [ y ] = mymod2pi( x )
%MYMOD2PI Переводи число в интервал +-pi

y = mod(x+pi, 2*pi) - pi;
y = x;
end

