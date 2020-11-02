%% STEP1: load files 

close all;clc;clear all;
addpath('toolbox');
addpath('tensorlab_2016-03-28');


% load mask, B0 map, T1 map, origin image: Slice 10,offsets
load('amidedata.mat');

% display T1 map
h1=figure(1);
set(gca,'Position',[0.05 0.05 0.9 0.9]);
T1_map(~mask)=0;
imagesc(T1_map,[0,1.5]);
title('T1 map (s)')
colormap(gray)
set(gcf,'Position',[100 500 350 350]);
axis off
hold off

% display B0 map
h2=figure(2);
set(gca,'Position',[0.05 0.05 0.9 0.9]);
B0_map(~mask)=0;
imagesc(B0_map,[-0.8,0.8]);
title('B0 map (ppm)')
colormap(gray)
set(gcf,'Position',[500 500 350 350]);
axis off
hold off

%% STEP2: obtain Z map & R map

% fisrt: use mask to process origin image 
% Second: Fit CEST 

% saturation power (uT)
stp = 1.4; 

[~,cestinspect,Z,R] = amide_process(mask,cestimgs,Offsets,B0_map,T1_map,stp);

%% STEP3 : plot Z map and R map 

% display Z map
h3=figure(3);
set(gca,'Position',[0.05 0.05 0.9 0.9]);
imagesc(Z,[0,4]);
title('Zamide map (%)')
colormap(inferno)
set(gcf,'Position',[100 100 350 350]);
axis off
hold off

% display R map
h4=figure(4);
set(gca,'Position',[0.05 0.05 0.9 0.9]);
imagesc(R,[0,60]);
title('Ramide map (10-3s-1)')
colormap(inferno)
set(gcf,'Position',[500 100 350 350]);
axis off
hold off

% display Z-spectrum of whole slice
h5=figure(5);
set(gca,'Position',[0.1 0.08 0.85 0.85]);
plot(cestinspect(:,1),cestinspect(:,2),'o-','LineWidth',2,'MarkerSize',6);
title('Z-spectrum')
set(gca,'XDir','reverse');
set(gcf,'Position',[900 100 350 350]);




