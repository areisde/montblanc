function [Heart,time] = Nstd(meanHR,stdHR,HR,N)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    i=1;
    for k=1:1:length(HR)
        if HR(k) > meanHR + N*stdHR 
            Heart(i,:) = HR(k);
            time(i,:) = k;
            i = i+1;
        end
    end

end

