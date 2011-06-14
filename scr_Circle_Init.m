Commut_Phase = ones(1,C+1);
Commut_Change = zeros(1,C+1);
for c = 2:(C+1)
    if ~mod(c, fix(1/Tc/freq_analog_change))
        Commut_Phase(c) = Commut_Phase(c-1) + 1*1;
        Commut_Change(c) = 1;
        if Commut_Phase(c) == 4
            Commut_Phase(c) = 1;
        end
    else
        Commut_Phase(c) = Commut_Phase(c-1);
    end
end