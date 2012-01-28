%> @file main.m
%> @brief Модель фильтра Калмана с оценками периодических скачков для
%> антенного коммутатора в случае 3 аналоговых частей + фильтр оценки 
%> второй разности аналоговых частей.
%> @author Корогодин И.В.
%> @date   24 May 2011
%> @todo Фильтр оценки скачков второго порядка; разобраться с перепутанными скачками
% Моделирование производится согласно теоретическим выкладкам:
% http://srns.ru/wiki/Blog:Korogodin/03.06.2011,_Алгоритм_оценки_задержки_а
% налоговых_частей_в_случае_трех_антенн

clear 
clc

load([pwd '/RealData/Data_20120128.mat']);

Tmod = 600; %s

Tc = 0.005; % Интервал накопления в корреляторе
C = fix(Tmod/Tc);
t = Tc:Tc:Tmod; le_t = length(t);
stdn_IQ = 600;
qcno_dB = 30;
[A_IQ, qcno] = qcno_change(qcno_dB, stdn_IQ, Tc); % Амплитуда, соответсвующая выбранному qcno_dB

std_Ud = sqrt( 2 / (qcno*Tc) );

F = [1 Tc Tc^2/2;
     0 1  Tc;
     0 0  1      ]; % Переходная матрица
 
F2 = [1 Tc;
      0 1];
 
H = 1; % Hz, полоса

K = nan(3,1); % Вектор-столбец коэффициентов фильтра
K(3) = (1.2*H)^3; % Коэффициенты непрерывной системы
K(2) = 2*(K(3))^(2/3);
K(1) = 2*(K(3))^(1/3);
K = K*Tc; % Коэффициенты дискретной системы

Kj = nan(2,1);
Hj = 1;
Kj(2) = (Hj / 0.53)^2;
Kj(1) = sqrt(2*Kj(2));
Kj = Kj*Tc; Kj(2) = 0*Kj(2)/1000;

neideal_jump = 1; % Способ передать системе истинные прыжки для оценки потенциальной точности
scr_ExtrIstEst_Init;

scr_Chi_Init; % Значение задержек в коммутаторе и разности аналоговых частей

freq_analog_change = 0.25; % Частота смены аналоговой части
scr_Circle_Init; % Определяем циклограмму переключений

csum_max = 64; csum = csum_max + 1;

init_arrays; 
for c = 1:C

    % Текущие оценки скачков 1->2 и 2->3
    scr_Jump_est; % Запускать до эволюции Delta!
    
    % Модель прохождения через коммутатор и аналоговые части
    if Commut_Phase(c) == 1 % Если сейчас коммутатор находится в фазе переключений (1)
        Psi21_1_izm = X21_1_ist(1) + Delta21_1_ist(1) + Chi_ph(2,2) - Chi_ph(1,1); % по первому спутнику
        Psi31_1_izm = X31_1_ist(1) + Delta31_1_ist(1) + Chi_ph(3,3) - Chi_ph(1,1);
        Psi21_2_izm = X21_2_ist(1) + Delta21_2_ist(1) + Chi_ph(2,2) - Chi_ph(1,1); % по второму спутнику
        Psi31_2_izm = X31_2_ist(1) + Delta31_2_ist(1) + Chi_ph(3,3) - Chi_ph(1,1);
        J21_1_extr = 0; J31_1_extr = 0;    % Ожидание подставки в этой фазе цикла
        J21_2_extr = 0; J31_2_extr = 0;    % ...и для второго спутника
    elseif Commut_Phase(c) == 2 % Для фазы (2) коммутатора 
        Psi21_1_izm = X21_1_ist(1) - Delta31_1_ist(1) + Chi_ph(2,1) - Chi_ph(1,3); % Первый
        Psi31_1_izm = X31_1_ist(1) + Delta21_1_ist(1) - Delta31_1_ist(1) + Chi_ph(3,2) - Chi_ph(1,3);
        Psi21_2_izm = X21_2_ist(1) - Delta31_2_ist(1) + Chi_ph(2,1) - Chi_ph(1,3); % Второй
        Psi31_2_izm = X31_2_ist(1) + Delta21_2_ist(1) - Delta31_2_ist(1) + Chi_ph(3,2) - Chi_ph(1,3);
        J21_1_extr = X21_12_1_j_extr(1); J31_1_extr = X31_12_1_j_extr(1);  % Скачок для первого спутника      
        J21_2_extr = X21_12_2_j_extr(1); J31_2_extr = X31_12_2_j_extr(1);  % для второго       
    elseif Commut_Phase(c) == 3 % Для фазы (3) коммутатора
        Psi21_1_izm = X21_1_ist(1) + Delta31_1_ist(1) - Delta21_1_ist(1) + Chi_ph(2,3) - Chi_ph(1,2); % Первый
        Psi31_1_izm = X31_1_ist(1) - Delta21_1_ist(1) + Chi_ph(3,1) - Chi_ph(1,2);
        Psi21_2_izm = X21_2_ist(1) + Delta31_2_ist(1) - Delta21_2_ist(1) + Chi_ph(2,3) - Chi_ph(1,2); % Второй
        Psi31_2_izm = X31_2_ist(1) - Delta21_2_ist(1) + Chi_ph(3,1) - Chi_ph(1,2);
        J21_1_extr = X21_23_1_j_extr(1); % Первый 
        J31_1_extr = X31_23_1_j_extr(1);       
        J21_2_extr = X21_23_2_j_extr(1); % Второй      
        J31_2_extr = X31_23_2_j_extr(1);  
    end
    
    psi_izm_21_1_c(c) = Psi21_1_izm;     psi_izm_31_1_c(c) = Psi31_1_izm;
    psi_izm_21_2_c(c) = Psi21_2_izm;     psi_izm_31_2_c(c) = Psi31_2_izm;
    
    
    if (Commut_Change(c) ~= 0)
        csum = 1;
    end
    
   
    % Система слежения за первой разностью фаз
    Ud21_1 = mymod2pi(Psi21_1_izm - X21_1_extr(1) - J21_1_extr) + std_Ud *randn(1,1); % Эмулятор дискриминатора
    if csum > csum_max
        X21_1_extr = X21_1_extr + K*Ud21_1; % Вектор оценок на c-й интервал (этап коррекции)
    end
    X21_1_est_c(c) = X21_1_extr(1);  X21_1_extr = F*X21_1_extr; % Экстраполяция на интервал c+1
    Ud31_1 = mymod2pi(Psi31_1_izm - X31_1_extr(1) - J31_1_extr)+ std_Ud *randn(1,1);
    if csum > csum_max
        X31_1_extr = X31_1_extr + K*Ud31_1; % Вектор оценок на c-й интервал
    end
    X31_1_est_c(c) = X31_1_extr(1);  X31_1_extr = F*X31_1_extr; % Экстраполяция на интервал c+1
    % аналогично для второго спутника
    Ud21_2 = mymod2pi(Psi21_2_izm - X21_2_extr(1) - J21_2_extr) + std_Ud *randn(1,1);
    if csum > csum_max
        X21_2_extr = X21_2_extr + K*Ud21_2; % Вектор оценок на c-й интервал
    end
    X21_2_est_c(c) = X21_2_extr(1);  X21_2_extr = F*X21_2_extr; % Экстраполяция на интервал c+1
    Ud31_2 = mymod2pi(Psi31_2_izm - X31_2_extr(1) - J31_2_extr) + std_Ud *randn(1,1);
    if csum > csum_max
        X31_2_extr = X31_2_extr + K*Ud31_2; % Вектор оценок на c-й интервал
    end
    X31_2_est_c(c) = X31_2_extr(1);  X31_2_extr = F*X31_2_extr; % Экстраполяция на интервал c+1
    

    
    if csum<=csum_max
        if Commut_Phase(c) == 2
            X21_12_1_j_extr = X21_12_1_j_extr + Kj*Ud21_1;
            X31_12_1_j_extr = X31_12_1_j_extr + Kj*Ud31_1;
            X21_12_2_j_extr = X21_12_2_j_extr + Kj*Ud21_2;
            X31_12_2_j_extr = X31_12_2_j_extr + Kj*Ud31_2;            
        elseif Commut_Phase(c) == 3
            X21_23_1_j_extr = X21_23_1_j_extr + Kj*Ud21_1;
            X31_23_1_j_extr = X31_23_1_j_extr + Kj*Ud31_1;
            X21_23_2_j_extr = X21_23_2_j_extr + Kj*Ud21_2;
            X31_23_2_j_extr = X31_23_2_j_extr + Kj*Ud31_2;
        end            
    end
    if ~neideal_jump
        X21_12_1_j_extr(1) = J21_12_1_ist_c(c);
        X31_12_1_j_extr(1) = J31_12_1_ist_c(c);
        X21_12_2_j_extr(1) = J21_12_2_ist_c(c);
        X31_12_2_j_extr(1) = J31_12_2_ist_c(c);            
        X21_23_1_j_extr(1) = J21_23_1_ist_c(c);
        X31_23_1_j_extr(1) = J31_23_1_ist_c(c);
        X21_23_2_j_extr(1) = J21_23_2_ist_c(c);
        X31_23_2_j_extr(1) = J31_23_2_ist_c(c);
    end
    
    csum = csum+1;
   
    x1_nabla = H1_nabla^-1 * J1_nabla; % Решение только по скачку 1->2
    x2_nabla = H2_nabla^-1 * J2_nabla; % Решение только по скачку 1->3
    x_nabla = (H_nabla'*H_nabla)^-1*H_nabla' * J_nabla; % Общее решение по всем скачкам
    
    Nabla21_c(c) = x_nabla(1);
    Nabla31_c(c) = x_nabla(2);
    Nabla21x1_c(c) = x1_nabla(1);
    Nabla31x1_c(c) = x1_nabla(2);
    Nabla21x2_c(c) = x2_nabla(1);
    Nabla31x2_c(c) = x2_nabla(2);
    
    
    % Эволюция разностей задержек в аналоговых частях
    Delta21_1_c(c) = Delta21_1_ist(1); Delta31_1_c(c) = Delta31_1_ist(1);
    Delta21_1_ist = F*Delta21_1_ist + randn(1,1)*std_Delta;
    Delta31_1_ist = F*Delta31_1_ist + randn(1,1)*std_Delta;    
    % ...аналогочино для второго спутника
    Delta21_2_c(c) = Delta21_2_ist(1); Delta31_2_c(c) = Delta31_2_ist(1);
    Delta21_2_ist = Delta21_1_ist + [pi/8; 0; 0];
    Delta31_2_ist = Delta31_1_ist + [-pi/10; 0; 0];

    
    % Эволюция истинного значения первой разности фаз
    X21_1_ist_c(c) = X21_1_ist(1); X31_1_ist_c(c) = X31_1_ist(1);
    X21_1_ist = F*X21_1_ist + randn(1,1)*std_Psi;
    X31_1_ist = F*X31_1_ist + randn(1,1)*std_Psi;
    % ...аналогично для второго спутника
    X21_2_ist_c(c) = X21_2_ist(1); X31_2_ist_c(c) = X31_2_ist(1);
    X21_2_ist = F*X21_2_ist + randn(1,1)*std_Psi;
    X31_2_ist = F*X31_2_ist + randn(1,1)*std_Psi;
    
    scr_J2pi;
   
    X21_12_1_j_extr = F2 * X21_12_1_j_extr;
    X31_12_1_j_extr = F2 * X31_12_1_j_extr;
    X21_23_1_j_extr = F2 * X21_23_1_j_extr;
    X31_23_1_j_extr = F2 * X31_23_1_j_extr;    
    X21_12_2_j_extr = F2 * X21_12_2_j_extr;
    X31_12_2_j_extr = F2 * X31_12_2_j_extr;
    X21_23_2_j_extr = F2 * X21_23_2_j_extr;
    X31_23_2_j_extr = F2 * X31_23_2_j_extr;
    if ~mod(10*c, C)
        fprintf('Done: %.0f%% \n', 100*c/C);
    end
end

hF = 0;
% hF = figure(hF+1);
% plot( t, Commut_Phase(1:le_t), t, Commut_Change(1:le_t));
% xlabel('t, sec');
% ylabel('Commut Phase, Commut Change');

hF = figure(hF+1);
subplot(1, 2, 1);
plot(t, X21_1_est_c, t, psi_izm_21_1_c, t, X21_1_ist_c, ...
     t, X31_1_est_c, t, psi_izm_31_1_c, t, X31_1_ist_c);
xlabel('t, sec');
ylabel('\Psi, rad for 1st SV');
legend('\Psi_{21, est}^{(1)}', '\Psi_{21, izm}^{(1)}', '\Psi_{21, ist}^{(1)}', ...
       '\Psi_{31, est}^{(1)}', '\Psi_{31, izm}^{(1)}', '\Psi_{31, ist}^{(1)}')

subplot(1, 2, 2);
plot(t, X21_2_est_c, t, psi_izm_21_2_c, t, X21_2_ist_c, ...
     t, X31_2_est_c, t, psi_izm_31_2_c, t, X31_2_ist_c);
xlabel('t, sec');
ylabel('\Psi, rad for 2nd SV');
legend('\Psi_{21, est}^{(2)}', '\Psi_{21, izm}^{(2)}', '\Psi_{21, ist}^{(2)}', ...
       '\Psi_{31, est}^{(2)}', '\Psi_{31, izm}^{(2)}', '\Psi_{31, ist}^{(2)}')

hF = figure(hF+1); subN = 1; 
subplot(2,2,subN); subN = subN+1;
plot(t, J21_12_1_c, t, J21_12_1_ist_c, ...
     t, J31_12_1_c, t, J31_12_1_ist_c);
xlabel('t, sec');
ylabel('Jump 12 for 1st SV');
legend('J_{21,extr}^{1->2, (1)}', 'J_{21,ist}^{1->2, (1)}', ...
       'J_{31,extr}^{1->2, (1)}', 'J_{31,ist}^{1->2, (1)}');

subplot(2,2,subN); subN = subN+1;
plot(t, J21_23_1_c, t, J21_23_1_ist_c, ...
     t, J31_23_1_c, t, J31_23_1_ist_c);
xlabel('t, sec');
ylabel('Jump 13 for 1st SV');
legend('J_{21,extr}^{1->3, (1)}', 'J_{21,ist}^{1->3, (1)}', ...
       'J_{31,extr}^{1->3, (1)}', 'J_{31,ist}^{1->3, (1)}')

subplot(2,2,subN); subN = subN+1;
plot(t, J21_12_2_c, t, J21_12_2_ist_c, ...
     t, J31_12_2_c, t, J31_12_2_ist_c);
xlabel('t, sec');
ylabel('Jump 12 for 2st SV');
legend('J_{21,extr}^{1->2, (2)}', 'J_{21,ist}^{1->2, (2)}', ...
       'J_{31,extr}^{1->2, (2)}', 'J_{31,ist}^{1->2, (2)}');

subplot(2,2,subN);  
plot(t, J21_23_2_c, t, J21_23_2_ist_c, ...
     t, J31_23_2_c, t, J31_23_2_ist_c);
xlabel('t, sec');
ylabel('Jump 13 for 2st SV');
legend('J_{21,extr}^{1->3, (2)}', 'J_{21,ist}^{1->3, (2)}', ...
       'J_{31,extr}^{1->3, (2)}', 'J_{31,ist}^{1->3, (2)}')


hF = figure(hF+1); subN = 1;
subplot(2,2,subN); subN = subN+1;
plot(t, Nabla21_c, t, Nabla21x1_c, t, Nabla21x2_c, t, Delta21_2_c - Delta21_1_c);
xlabel('t, sec');
ylabel('All \nabla_{21}: common, 12, 23');
legend('\nabla_{21,common, est}', '\nabla_{21,J12,est}', '\nabla_{21,J23,est}', '\nabla_{21,ist}')

subplot(2,2,subN); subN = subN+1;
plot(t, Nabla31_c, t, Nabla31x1_c, t, Nabla31x2_c, t, Delta31_2_c - Delta31_1_c);
xlabel('t, sec');
ylabel('All \nabla_{31}: common, 12, 23');
legend('\nabla_{31,common, est}', '\nabla_{31,J12,est}', '\nabla_{31,J23,est}', '\nabla_{31,ist}')

subplot(2,2,subN); subN = subN+1;
plot(t, dJ_21_12_c, t, dJ_31_12_c, t, dJ_21_23_c, t, dJ_31_23_c);
xlabel('t, sec');
ylabel('J_{\nabla}');
legend('J_{\nabla,21}^{1->2}', 'J_{\nabla,31}^{1->2}', 'J_{\nabla,21}^{2->3}', 'J_{\nabla,31}^{2->3}')

subplot(2,2,subN); subN = subN+1;
plot(t, Delta21_1_c, t, Delta21_2_c, t, Delta31_1_c, t, Delta31_2_c);
xlabel('t, sec');
ylabel('\Delta');
legend('\Delta_{21}^{(1)}',  '\Delta_{21}^{(2)}',  '\Delta_{31}^{(1)}', '\Delta_{31}^{(2)}')

hF = figure(hF+1); subN = 1;
subplot(2,2,subN); subN = subN+1;
plot(t, X21_2_est_c - X21_1_est_c - Nabla21_c, t, X21_2_ist_c - X21_1_ist_c);
xlabel('t, sec');
ylabel('\Delta \Psi_{21}');
legend('Estimation', 'True');

subplot(2,2,subN); subN = subN+1;
plot(t, X31_2_est_c - X31_1_est_c - Nabla31_c, t, X31_2_ist_c - X31_1_ist_c);
xlabel('t, sec');
ylabel('\Delta \Psi_{31}');
legend('Estimation', 'True')

Err_dPsi21 =  X21_2_est_c - X21_1_est_c - Nabla21_c - X21_2_ist_c + X21_1_ist_c;
tmp = Err_dPsi21(end) - mod(Err_dPsi21(end), 2*pi);
Err_dPsi21 = Err_dPsi21 - tmp;
subplot(2,2,subN); subN = subN+1;
plot(t, (Err_dPsi21)*180/2/pi, t, (Err_dPsi21 + 2*pi)*180/2/pi, t, (Err_dPsi21 - 2*pi)*180/2/pi);
xlabel('t, sec');
ylabel('\delta \Delta \Psi_{21}, mm');

Err_dPsi31 =  X31_2_est_c - X31_1_est_c - Nabla31_c - X31_2_ist_c + X31_1_ist_c;
tmp = Err_dPsi31(end) - mod(Err_dPsi31(end), 2*pi);
Err_dPsi31 = Err_dPsi31 - tmp;
subplot(2,2,subN); subN = subN+1;
plot(t, (Err_dPsi31)*180/2/pi, t, (Err_dPsi31 + 2*pi)*180/2/pi, t, (Err_dPsi31 - 2*pi)*180/2/pi);
xlabel('t, sec');
ylabel('\delta \Delta \Psi_{31}, mm');

scr_SKO_Calc;