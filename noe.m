%% STEP1: load files 

close all;clc;clear all;
addpath('toolbox');
addpath('tensorlab_2016-03-28');

% load mask, B0 map, T1 map, offsets and origin image slice 7
load('noedata.mat');


%% STEP2: obtain Z map & R map

% fisrt: use mask to process origin image 
% Second: Fit 

[cestinspect,NOE,RNOE] = noe_process(cestimgs,Offsets,mask,B0_map,T1_map);

%% STEP3 : plot NOE map and RNOE map 

% display NOE map 
h1=figure(1);
set(gca,'Position',[0.05 0.05 0.9 0.9]);
imagesc(NOE(5:90,5:90),[0,10]); 
colormap('inferno')
title('ZNOE map (%)')
set(gcf,'Position',[100 100 350 350]);
axis off
hold off

% display RNOE map 
h2=figure(2);
set(gca,'Position',[0.05 0.05 0.9 0.9]);
imagesc(RNOE(5:90,5:90),[0,100]); 
colormap('inferno')
title('RRNOE map (10-3 s-1)')
set(gcf,'Position',[500 100 350 350]);
axis off
hold off

% display Z-spectrum of whole slice
h3=figure(3);
set(gca,'Position',[0.1 0.08 0.85 0.85]);
plot(cestinspect(:,1),cestinspect(:,2),'o','MarkerSize',6);
title('Z-spectrum')
set(gca,'XDir','reverse');
set(gcf,'Position',[900 100 350 350]);
xlim([-10 0]);
ylim([0.9 1]);

