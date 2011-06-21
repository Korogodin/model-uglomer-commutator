%> @file scr_Jump_est.m
%> @brief Jump's estimation and true value saving. Run before update Deltas
%> @author Korogodin I.V.
%> @date   14 June 2011
%> @todo 

% Текущие экстраполяции скачков первых разностей
J21_12_1_c(c) = X21_12_1_j_extr(1); J31_12_1_c(c) = X31_12_1_j_extr(1);
J21_23_1_c(c) = X21_23_1_j_extr(1); J31_23_1_c(c) = X31_23_1_j_extr(1);
J21_12_2_c(c) = X21_12_2_j_extr(1); J31_12_2_c(c) = X31_12_2_j_extr(1);
J21_23_2_c(c) = X21_23_2_j_extr(1); J31_23_2_c(c) = X31_23_2_j_extr(1);

% Истинные значения скачков первых разностей
J21_12_1_ist_c(c) = - Delta21_1_ist(1) - Delta31_1_ist(1) + Chi_ph(2,1) - Chi_ph(1,3) + Chi_ph(1,1) - Chi_ph(2,2);
J31_12_1_ist_c(c) =   Delta21_1_ist(1) - 2*Delta31_1_ist(1) + Chi_ph(3,2) - Chi_ph(1,3) - Chi_ph(3,3) + Chi_ph(1,1);
J21_12_2_ist_c(c) = - Delta21_2_ist(1) - Delta31_2_ist(1) + Chi_ph(2,1) - Chi_ph(1,3) + Chi_ph(1,1) - Chi_ph(2,2);
J31_12_2_ist_c(c) =   Delta21_2_ist(1) - 2*Delta31_2_ist(1) + Chi_ph(3,2) - Chi_ph(1,3) - Chi_ph(3,3) + Chi_ph(1,1);
% ВНИМАНИЕ! На самом деле это разность между 1 и 3 фазой, а не между 2 и 3, как было в исходном варианте:
J21_23_1_ist_c(c) = - 2*Delta21_1_ist(1) + Delta31_1_ist(1) + Chi_ph(1,1) - Chi_ph(1,2) - Chi_ph(2,2) + Chi_ph(2,3);
J31_23_1_ist_c(c) = -   Delta21_1_ist(1) - Delta31_1_ist(1) + Chi_ph(1,1) - Chi_ph(1,2) + Chi_ph(3,1) - Chi_ph(3,3);
J21_23_2_ist_c(c) = - 2*Delta21_2_ist(1) + Delta31_2_ist(1) + Chi_ph(1,1) - Chi_ph(1,2) - Chi_ph(2,2) + Chi_ph(2,3);
J31_23_2_ist_c(c) = -   Delta21_2_ist(1) - Delta31_2_ist(1) + Chi_ph(1,1) - Chi_ph(1,2) + Chi_ph(3,1) - Chi_ph(3,3);

% Скачки вторых разностей
dJ_21_12_c(c) = J21_12_2_c(c) - J21_12_1_c(c);
dJ_31_12_c(c) = J31_12_2_c(c) - J31_12_1_c(c);
dJ_21_23_c(c) = J21_23_2_c(c) - J21_23_1_c(c);
dJ_31_23_c(c) = J31_23_2_c(c) - J31_23_1_c(c);
% if dJ_21_12_c(c) > pi
%    dJ_21_12_c(c) = dJ_21_12_c(c) - 2*pi;
% elseif dJ_21_12_c(c) < -pi
%    dJ_21_12_c(c) = dJ_21_12_c(c) + 2*pi;
% end
% if dJ_31_12_c(c) > pi
%    dJ_31_12_c(c) = dJ_31_12_c(c) - 2*pi;
% elseif dJ_31_12_c(c) < -pi
%    dJ_31_12_c(c) = dJ_31_12_c(c) + 2*pi;
% end
% if dJ_21_23_c(c) > pi
%    dJ_21_23_c(c) = dJ_21_23_c(c) - 2*pi;
% elseif dJ_21_23_c(c) < -pi
%    dJ_21_23_c(c) = dJ_21_23_c(c) + 2*pi;
% end
% if dJ_31_23_c(c) > pi
%    dJ_31_23_c(c) = dJ_31_23_c(c) - 2*pi;
% elseif dJ_31_23_c(c) < -pi
%    dJ_31_23_c(c) = dJ_31_23_c(c) + 2*pi;
% end

J_nabla = ...
    [dJ_21_12_c(c); 
     dJ_31_12_c(c);
     dJ_21_23_c(c); 
     dJ_31_23_c(c)];
J1_nabla = ...
    [dJ_21_12_c(c); 
     dJ_31_12_c(c)];
J2_nabla = ...
    [dJ_21_23_c(c); 
     dJ_31_23_c(c)];