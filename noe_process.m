function [cestinspect,NOE,RNOE] = noe_process(cestimgs,Offsets,mask,B0_map,T1_map)

    % This function has B0 T1 correction
    % compute the MLSVD of the tensor
    [Ue,Se,~] = mlsvd(cestimgs,[48 48 4]);
    IMGtmp_process =lmlragen(Ue, Se);
 
    %above readout image and convert to Z-spectra
    CESTimg=IMGtmp_process(:,:,:)./IMGtmp_process(:,:,2);
    
    %remove first two M0 points
    FreqPPM=Offsets(3:end);
    CESTimg=CESTimg(:,:,3:end);
    
    %get whole maks CEST Z-spectrum for inspection
     offset_num = size(FreqPPM,1);
     cestinspect = zeros(offset_num,2);
     for i=1:offset_num
         cestinspect(:,1)=FreqPPM;
         tmp=CESTimg(:,:,i);
         cestinspect(i,2)=mean(tmp(mask));
     end

     
    NXALL = size(CESTimg,1);
    NYALL = size(CESTimg,2);
    NOE= zeros(NXALL,NYALL);
    RNOE = zeros(NXALL,NYALL);
    
    for idx=1:NXALL
        for idy=1:NYALL
            if (mask(idx,idy)) 
                
                % T1 correction
                if (T1_map(idx,idy) <= 0.3) || (T1_map(idx,idy) >= 3)
                    R1 = 1;
                else
                    R1 = 1/T1_map(idx,idy);
                end   
                
                % B0 correction
                B0offset = B0_map(idx,idy);

                tmp=squeeze(CESTimg(idx,idy,1:4));
            
                %background linefit
                pbak = polyfit(FreqPPM(1:4),tmp,0);
                bakval = polyval(pbak,-8+B0offset);
                tmp=squeeze(CESTimg(idx,idy,5:8));
                
                %noe linear fit 
                x = [ones(length(FreqPPM(5:8)),1),FreqPPM(5:8)];
                y = tmp; 
                b = regress(y,x);
                noeval = b(1) * 1 + b(2) * (-3.5 + B0offset);

                Rmt=(R1/bakval-R1);
                Rnoe=(R1/noeval-R1);
                NOE(idx,idy)=100*(bakval-noeval);
                RNOE(idx,idy)=1000*(Rnoe-Rmt);
            end 
        end
    end
end


