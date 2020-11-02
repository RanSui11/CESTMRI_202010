function [displayimg_origin,cestinspect,Z,R] = amide_process(mask,cestimgs,Offsets,B0_map,T1_map,stp)

    % This function has B0 and T1 correction.


    IMGtmp_origin=cestimgs;
    displayimg_origin=IMGtmp_origin(:,:,1); 
    displayimg_origin(~mask)=0;
    B0_map(~mask) = 0;

    % compute the MLSVD of the tensor
    [Ue,Se,~] = mlsvd(cestimgs,[48 48 10]);
    IMGtmp_process =lmlragen(Ue, Se);

    %refine MASK image
    displayimg_process=IMGtmp_process(:,:,1);
    displayimg_process(~mask)=0;
    NXALL=size(IMGtmp_process,1);
    NYALL=size(IMGtmp_process,2);
    for idx=1:NXALL
       for idy=1:NYALL
            if (mask(idx,idy))
                if (displayimg_process(idx,idy)<0.7*mean2(displayimg_process(mask)))
                    mask(idx,idy)=false;
                end
            end
       end
    end



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
     
     % fit each point
     Z=zeros(NXALL,NYALL);
     R = zeros(NXALL,NYALL);
     idxall=0;

     for idx=1:NXALL
        for idy=1:NYALL
            idxall=idxall+1;
            
            if (mask(idx,idy))
                
                % B0 correction
                B0Shift = B0_map(idx,idy);
                
                Z_spectrum=CESTimg(idx,idy,:);
                Z_spectrum=squeeze(Z_spectrum);
                
                %Fit PLOT 

                FitParam.WholeRange = [1.6+B0Shift,6.8+B0Shift];    % CEST peak parameters
                FitParam.PeakOffset = 3.5+B0Shift;
                FitParam.PeakRange = [2.5+B0Shift,4.3+B0Shift];

                FitParam.Magfield = 42.58*3; % 3 T
                
                % T1 correction
                if T1_map(idx,idy) == 0
                    FitParam.R1 = 1;
                else
                    FitParam.R1 = 1/T1_map(idx,idy);
                end % 1/T1value(second) update T1：09/21

                FitParam.satpwr = stp; % saturation power (uT)
                FitParam.tsat =100; % saturation length (second) 100s to make it steady-state

                [FitResult,FitParam] = PLOF(FreqPPM,Z_spectrum,FitParam);
                Z(idx,idy)=100*FitResult.DeltaZpeak;
                R(idx,idy) = 1000*FitResult.Rpeak;
                
            end
            waitbar(idxall/(NXALL*NYALL));
        end
    end
end


    





