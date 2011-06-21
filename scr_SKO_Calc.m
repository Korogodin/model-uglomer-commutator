
Err31_1 = (Err_dPsi31)*180/2/pi;
Err31_2 = (Err_dPsi31 + 2*pi)*180/2/pi;
Err31_3 = (Err_dPsi31 - 2*pi)*180/2/pi;

Err21_1 = (Err_dPsi21)*180/2/pi;
Err21_2 = (Err_dPsi21 + 2*pi)*180/2/pi;
Err21_3 = (Err_dPsi21 - 2*pi)*180/2/pi;

SE_31_1 = Err31_1(20000:end)*Err31_1(20000:end)' / length(Err31_1(20000:end));
SE_31_2 = Err31_2(20000:end)*Err31_2(20000:end)' / length(Err31_2(20000:end));
SE_31_3 = Err31_3(20000:end)*Err31_3(20000:end)' / length(Err31_3(20000:end));

SE_21_1 = Err21_1(20000:end)*Err21_1(20000:end)' / length(Err21_1(20000:end));
SE_21_2 = Err21_2(20000:end)*Err21_2(20000:end)' / length(Err21_2(20000:end));
SE_21_3 = Err21_3(20000:end)*Err21_3(20000:end)' / length(Err21_3(20000:end));

ComErr = sqrt(min([SE_31_1 SE_31_2 SE_31_3]) + min([SE_21_1 SE_21_2 SE_21_3]) / 2);

fprintf('ComErr = %f mm \n', ComErr);