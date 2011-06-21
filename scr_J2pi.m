%> @file scr_J2pi.m
%> @brief Приведение всех однотипных скачков к примерно одинаковым
%значениям
%> @author Korogodin, I.V.
%> @date   21 June 2011
%> @todo 

if isnan(J21_12_buf)
    J21_12_buf = X21_12_1_j_extr(1);
else
    X21_12_1_j_extr(1) = mymod2pi(X21_12_1_j_extr(1) - J21_12_buf) + J21_12_buf;
    J21_12_buf = X21_12_1_j_extr(1);
    X21_12_2_j_extr(1) = mymod2pi(X21_12_2_j_extr(1) - J21_12_buf) + J21_12_buf;
    J21_12_buf = X21_12_2_j_extr(1);
end

if isnan(J31_12_buf)
    J31_12_buf = X31_12_1_j_extr(1);
else
    X31_12_1_j_extr(1) = mymod2pi(X31_12_1_j_extr(1) - J31_12_buf) + J31_12_buf;
    J31_12_buf = X31_12_1_j_extr(1);
    X31_12_2_j_extr(1) = mymod2pi(X31_12_2_j_extr(1) - J31_12_buf) + J31_12_buf;
    J31_12_buf = X31_12_2_j_extr(1);
end


if isnan(J21_23_buf)
    J21_23_buf = X21_23_1_j_extr(1);
else
    X21_23_1_j_extr(1) = mymod2pi(X21_23_1_j_extr(1) - J21_23_buf) + J21_23_buf;
    J21_23_buf = X21_23_1_j_extr(1);
    X21_23_2_j_extr(1) = mymod2pi(X21_23_2_j_extr(1) - J21_23_buf) + J21_23_buf;
    J21_23_buf = X21_23_2_j_extr(1);
end

if isnan(J31_23_buf)
    J31_23_buf = X31_23_1_j_extr(1);
else
    X31_23_1_j_extr(1) = mymod2pi(X31_23_1_j_extr(1) - J31_23_buf) + J31_23_buf;
    J31_23_buf = X31_23_1_j_extr(1);
    X31_23_2_j_extr(1) = mymod2pi(X31_23_2_j_extr(1) - J31_23_buf) + J31_23_buf;
    J31_23_buf = X31_23_2_j_extr(1);
end