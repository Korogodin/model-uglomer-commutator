qcno_ComErr =...
    [23     25     27   29     31      33   35     37      39      41      43      45      47      49];
ComErr = ...        
    [9.798  8.09   6.01 4.85   3.77    2.8  2.5    1.9     1.42    1.239   0.9846  0.74    0.6024  0.471863]; % mm 1 sigma

figure(999)
plot(qcno_ComErr, ComErr);
xlabel('q_{c/n0}, dBHz')
ylabel('\sigma_{\nabla}, mm')
title('\Delta \Delta phase error')
grid on