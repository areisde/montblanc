%% Read csv file 
clc;
clear all;
Heart = readtable('04.12.2021/heart_rate.csv');
Step_count = readtable('04.12.2021/step_count.csv');

%Extract Heart Rate and Acceleration magnitude
HR = table2array(Heart(:,1));
Time_HR = table2array(Heart(:,4));

Step = table2array(Step_count(:,2));
Time_Step = table2array(Step_count(:,3));

Hour_begin = Time_HR(1);


%% NSTD

meanHR = mean(HR);
stdHR = std(HR);
N = 2;

[Stressvalues_HR,Timevalue_HR] = Nstd(meanHR, stdHR, HR, N);

for i = 1:1:length(Timevalue_HR)
    Time_stress(i,:) = Time_HR(Timevalue_HR(i));
end

%% Filtrering step  

k = 1;
for i=1:1:length(Step)
    if Step(i) > 15
        Step_F(k,:) = Step(i);
        Time_Step_F(k,:) = Time_Step(i);
        k = k+1;
    end
end

%% Compare step count 

k = 1;
for i = 1:1:length(Time_stress)
    a = find(Time_Step_F == Time_stress(i));
    if isempty(a)
        Final_stress(k,:) = Stressvalues_HR(i);
        Real_time_stress(k,:) = Time_stress(i);
        k = k+1;
    end
end


%% Convert datetime into index


k = 1;
for i = 1:1:length(Time_HR)
    a = find(Real_time_stress == Time_HR(i));
    if a
        Final_time(k,:) = i;
        k = k+1;
    end
end


%% Separate phases of stress 

%Create different column with different period of stress through the day
%1 stress period = 1 r
j = 1;
i = 1;
for k=1:1:length(Final_time)-1
    if Final_time(k+1)-Final_time(k)<10
        Peaks_time(i,j) = Final_time(k);
        Peaks_HR(i,j) = Final_stress(k);
        i = i+1;
    else 
        Peaks_time(i,j) = Final_time(k);
        Peaks_HR(i,j) = Final_stress(k);
        j = j+1;
        i = 1;
    end
end

%% COnvert into seconds

X = Peaks_time(1,:);

for k=1:1:size(Peaks_time,2)
    tmp = Peaks_HR(:,k);
    tmp = tmp(tmp~=0);
    Y1(k) = round(mean(tmp),1);
    Y2(k) = length(tmp)*60;
end
    
%% Write into excel

filename = 'TMP.xlsx';
new_sheet1 = 'User22-HR';
new_sheet3 = 'User22-Mean';


writematrix(Peaks_HR,filename,'Sheet',new_sheet1,'Range','B2');
writematrix(X,filename,'Sheet',new_sheet3,'Range','B4');
writematrix(Y1,filename,'Sheet',new_sheet3,'Range','B2');
writematrix(Y2,filename,'Sheet',new_sheet3,'Range','B3');




