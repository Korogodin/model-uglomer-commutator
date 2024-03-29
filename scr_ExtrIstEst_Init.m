%> @file scr_ExtrIst_Init.m
%> @brief Extrapolations, Estimations and True Values Init
%> @author Korogodin, I.V.
%> @date   24 May 2011
%> @todo 


X21_1_extr = [0; 0; 0]; % Экстраполяции разности фаз
X31_1_extr = [0; 0; 0]; % для первого спутника
X21_2_extr = [0; 0; 0]; % Экстраполяции разности фаз
X31_2_extr = [0; 0; 0]; % для второго спутника

X21_1_ist = [rand(1,1)*50; 0; 0]; % Истинные значения разности фаз 
X31_1_ist = [rand(1,1)*50; 0; 0];% для первого... 
X21_2_ist = [rand(1,1)*50; 0; 0]; % ...и второго спутников  
X31_2_ist = [rand(1,1)*50; 0; 0]; 
std_Psi = [0; 0; 0.0001];

Delta21_1_ist = [rand(1,1)*pi; 0; 0]; % Разность набегов фаз в аналоговых частях
Delta31_1_ist = [rand(1,1)*pi; 0; 0];
Delta21_2_ist = [rand(1,1)*pi; 0; 0];
Delta31_2_ist = [rand(1,1)*pi; 0; 0];
if neideal_jump
    std_Delta = [0; 0; 0.00000005];
else
    std_Delta = [0; 0; 0];
end

X21_12_1_j_extr = [0; 0 ]; % Оценки скачков
X31_12_1_j_extr = [0; 0 ]; % для первого спутника...
X21_23_1_j_extr = [0; 0 ]; 
X31_23_1_j_extr = [0; 0 ]; 
X21_12_2_j_extr = [0; 0 ]; % ... и для второго
X31_12_2_j_extr = [0; 0 ]; 
X21_23_2_j_extr = [0; 0 ]; 
X31_23_2_j_extr = [0; 0 ]; 

J21_12_buf = NaN; J31_12_buf = NaN;
J21_23_buf = NaN; J31_23_buf = NaN;

