%% Read csv file 
clear all;
T = readtable('DataPaper/user_5/Actigraph.csv');

%Extract Heart Rate and Acceleration magnitude
HR = table2array(T(:,6));
ACC_Mag = table2array(T(:,11));
Hour_begin = T(1,13);


%% Down sample
q = 1000;    %Nombre de points voulus 
p1 = length(HR);
    
HR_R = round(resample(HR,q,p1),0);
ACC_mag_R = round(resample(ACC_Mag,q,p1),0);

%% Filtering

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

%Donnee superieur a moyenne + 2std, garde temps et valeur HR + ACC
%StressValues -> Valeur 'anormales' et Timevalues correspondant
[Stressvalues_HR,Timevalue_HR] = Nstd(meanHR, stdHR, HR, N);
[Stressvalues_Acc,Timevalue_Acc] = Nstd(meanAcc, stdAcc, ACC_Mag, N);


%Permet d'eliminer les temps en commun, et recree une variable de stress et
%le temps correspondant. 
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

% figure
% title('Mean HR value per stress period')
% xlabel('Time [s]')
% ylabel('HR')
% bar(X,Y1);
% 
% figure
% bar(X,Y2);
% title('Length of stress period ')
% xlabel('Time [s]')
% ylabel('Length [s]')




    
%% Write into excel

filename = 'Data-HR.xlsx';
new_sheet1 = 'User1-HR';
new_sheet2 = 'User1-Time';
new_sheet3 = 'User1-Mean';

writematrix(Peaks_HR,filename,'Sheet',new_sheet1,'Range','B2');
writematrix(X,filename,'Sheet',new_sheet3,'Range','B4');
writematrix(Y1,filename,'Sheet',new_sheet3,'Range','B2');
writematrix(Y2,filename,'Sheet',new_sheet3,'Range','B3');
writetable(Hour_begin,filename,'Sheet',new_sheet3,'Range','B6');



