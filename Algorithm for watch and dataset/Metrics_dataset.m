%% Read csv file 
clear all;
T = readtable('DataPaper/user_14/Actigraph.csv');
Questionnaire = readtable('DataPaper/user_14/questionnaire.csv');
Info = readtable('DataPaper/user_14/user_info.csv');
new_sheet1 = 'User22-HR';
new_sheet3 = 'User22-Mean';

%Extract Heart Rate and Acceleration magnitude
HR = table2array(T(:,6));
ACC_Mag = table2array(T(:,11));

Hour_begin = T(1,13);

%Stai 1 anxiety during test, short term anxiety
%Stai 2 general tendency of anxiety
STAI_1 = Questionnaire(1,3); %[20;80] <31 no anxiety 31-49 normal et +50 high level anxiety
STAI_2 = Questionnaire(1,4); % 
Anxiety = [STAI_1,STAI_2];
Pittsburg = Questionnaire(1,5); 
Daily_stress = Questionnaire(1,6);
Pitt_daily = [Pittsburg,Daily_stress];

weight = table2array(Info(1,3));
height = table2array(Info(1,4))/100;
age = table2array(Info(1,5));
BMI = round(weight/(height^2),2);
switch BMI
    case BMI*(BMI < 18.5)
        sante = 'Insuffisance pondérale';
    case BMI*((18.6 < BMI) && (BMI < 24.9))
        sante = 'Normal weight';
    case BMI*((25 < BMI) && (BMI < 29.9))
        sante = 'Overweight';
    case BMI*((30 < BMI) && (BMI < 34.9))
        sante = 'Obesity lvl 1';
    case BMI*((35 < BMI) && (BMI < 39.9))
        sante = 'Obesity lvl 2';
    otherwise
        sante = 'Obesity lvl 3';
end


%% Down sample (not used)
q = 1000;    %Nombre de points voulus 
p1 = length(HR);
    
HR_R = round(resample(HR,q,p1),0);
ACC_mag_R = round(resample(ACC_Mag,q,p1),0);

%% Filtering (not used)

fs = 30; %sampling freq
fc = 15; % cut-off freq
[m,n] = butter(2, 1.25*fc/fs/2);

Filter_HR = round(filtfilt(m,n,HR_R),0);
Filter_Acc = round(filtfilt(m,n,ACC_mag_R),0);

%% Extract metrics

meanHR = mean(HR);
stdHR = std(HR);
meanAcc = mean(ACC_Mag);
stdAcc = std(ACC_Mag);
N = 2;

%Value > mean + 2std, keep time and value HR + ACC
%StressValues -> weird values and correpsonding time values
[Stressvalues_HR,Timevalue_HR] = Nstd(meanHR, stdHR, HR, N);
[Stressvalues_Acc,Timevalue_Acc] = Nstd(meanAcc, stdAcc, ACC_Mag, N);

%Remove value if commun time, recreate a variable of stress with
%correpsondong time
i = 1;
for k=1:1:length(Timevalue_HR)
    test = find(Timevalue_Acc == Timevalue_HR(k));
    if isempty(test)
        Timevalue_HR_effective(i,:) = Timevalue_HR(k);
        Stressvalues_HR_effective(i,:) = HR(Timevalue_HR(k));
        i = i+1;
    end
end

%scatter(Time_HR,Stress_HR);

%% Separate phases of stress 

%Create different column with different period of stress through the day
%1 stress period = 1 row
j = 1;
i = 1;
for k=1:1:length(Timevalue_HR_effective)-1
    if Timevalue_HR_effective(k+1)-Timevalue_HR_effective(k)<100
        Peaks_time(i,j) = Timevalue_HR_effective(k);
        Peaks_HR(i,j) = Stressvalues_HR_effective(k);
        i = i+1;
    else 
        Peaks_time(i,j) = Timevalue_HR_effective(k);
        Peaks_HR(i,j) = Stressvalues_HR_effective(k);
        j = j+1;
        i = 1;
    end
end

%Delete row with less than 10 values, not corresponding to a real stress
B = [];
for k=1:1:size(Peaks_time,2)
    A = find(Peaks_time(:,k));
    if length(A) < 10
        B = [B k];
    end
end
Peaks_time(:,B)= [];
Peaks_HR(:,B)= [];

%Create 2 plots: 1 representing the mean value for each stress period
%The other represents the length of the stress period
for k=1:1:size(Peaks_time,2)
    tmp = Peaks_HR(:,k);
    tmp = tmp(tmp~=0);
    Y1(k) = round(mean(tmp),1);
    Y2(k) = length(tmp);
end

X = Peaks_time(1,:);

figure
bar(X,Y1);
title('Mean HR value per stress period')
xlabel('Time [s]')
ylabel('HR')


figure
bar(X,Y2);
title('Length of stress period ')
xlabel('Time [s]')
ylabel('Length [s]')




    
%% Write into excel

filename = 'TMP.xlsx';


writematrix(Peaks_HR,filename,'Sheet',new_sheet1,'Range','B2');
writematrix(X,filename,'Sheet',new_sheet3,'Range','B4');
writematrix(Y1,filename,'Sheet',new_sheet3,'Range','B2');
writematrix(Y2,filename,'Sheet',new_sheet3,'Range','B3');
writetable(Hour_begin,filename,'Sheet',new_sheet3,'Range','B6');
writetable(Pitt_daily,filename,'Sheet',new_sheet3,'Range','D6');
writematrix(BMI,filename,'Sheet',new_sheet3,'Range','G6');
writematrix(sante,filename,'Sheet',new_sheet3,'Range','H6');
writetable(Anxiety,filename,'Sheet',new_sheet3,'Range','I6');



