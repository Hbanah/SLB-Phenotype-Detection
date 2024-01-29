function [spectraInput, lambda] = AcquireDataCube(mainFolder, date, subFolders, spectraInput)

%load the data. check if there was an energy error and adjust the loadling line accordingly
[c, l] = size(spectraInput);

WN = 1;
indx2 = c+1;
for m=1:length(subFolders)
    dirStr = mainFolder + date + subFolders{m} + "\" + date + "*.brane";
    D = dir(dirStr);
    for n=1:length(D)
        specout_temp = zeros(1,1024);
        fid=fopen([D(n).folder,'\',D(n).name]);
        C_control = textscan(fid,'%s','delimiter','\t', 'headerlines',1);
        fclose(fid);

        if(WN)
        count = 1;
            Index = find(contains(C_control{1},'nm'));
            for g=Index+1:(Index+1+1023)
                lambda(count) = str2num(C_control{1}{g});
                count = count + 1;
            end
            WN = 0;
        end

        count = 1;
        Index = find(contains(C_control{1},'Spectrum - Dark'));
        for g=Index+1:(Index+1+1023)
            specout_temp(count) = str2num(C_control{1}{g});
            count = count + 1;
        end
        Index = find(contains(C_control{1},'Number_Of_Pulses'));
        pulses = str2num(C_control{1}{Index+1});
        spectraInput(indx2,:) = specout_temp./pulses;
        indx2=indx2+1;
        
    end
   
end

end