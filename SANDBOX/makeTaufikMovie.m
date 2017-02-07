%% Load Data
inFname='/Applications/freesurfer/subjects/NiAs/elec_recon/NiAs.pial';
elecCsv=csv2Cell(inFname,' ',2);

n_elec=size(elecCsv,1);
ras=zeros(n_elec,3);
for a=1:n_elec,
    for b=1:3,
        ras(a,b)=str2num(elecCsv{a,b});
    end
end

%% Plot electrodes in 3D rotation
figure(1);
set(gcf,'position',[360   514   951   410]);
clf;
% ax3d=sbplot(1,3,1);
axes('position',[0.0500 0.0800 0.4128 0.8150]);
h=plot3(ras(:,1),ras(:,2),ras(:,3),'.','markersize',25);
ax_lim=70;
axis([-1 1 -1 1 -1 1]*ax_lim);
hold on;
%axis square;
set(gca,'box','off','visible','off');


% READ SURFACE
surfacefolder='/Applications/freesurfer/subjects/NiAs/surf/';
surftype='pial';
for hem=1:2,
    if hem==1,
        [cort.vert cort.tri]=read_surf([surfacefolder 'rh.' surftype]);
    else
        [cort.vert cort.tri]=read_surf([surfacefolder 'lh.' surftype]);
    end
    
    if min(min(cort.tri))<1
        cort.tri=cort.tri+1; %sometimes this is needed sometimes not. no comprendo. DG
    end
    
    n_map_vert=size(cort.vert,1);
    map=ones(n_map_vert,3)*.7;
    %map=[.7 .7 .7]; %make it all grey
    if hem==1,
        triHR=tripatchDG(cort,1,map); %this plots the brain
    else
        triHL=tripatchDG(cort,1,map); %this plots the brain
    end
    
    %     if universalYes(rotate3d_active),
    %         rotate3d on;
%     else
%         rotate3d off;
%     end
end
shading interp; lighting gouraud; material dull;
l=light('Position',[0 1 0]);
view(180,0);


%%
for a=1:-.1:0,
   alpha(a); 
   pause(.1);
   drawnow;
end


%% rotate view
% az=0.5;
% el=0;
% view(az,el);
for a=1:1,
    n_rot=16;
    for i=1:n_rot,
        camorbit(2,0,'data',[0 0 1]);
        %camorbit(4,0,'camera');
        pause(.1);
        drawnow
    end
    for i=1:n_rot,
        camorbit(-2,0,'data',[0 0 1]);
        %camorbit(-4,0,'camera');
        pause(.1);
        drawnow
    end
end
%     camorbit(axH,4,0,'data',[0 0 1])
%     pause(.1);
%     drawnow

% mov(1:nFrames) = struct('cdata', [],...
%     'colormap', []);
% autorotate(dat.figId,dat.axH)

%     set(gcf,'PaperPositionMode','auto');
%     pause(1);
%     
%     mov(ct) = getframe(gcf);

%%
movie2avi(mov,sprintf('%s_final.avi',StimPair), 'compression', 'None','FPS',5);


%%
cfg=[];
cfg.figId=2;
cfg.view='r';
cfg.ignoreDepthElec='n';
cfg.opaqueness=.3;
cfg.title=[];
cfgOut=plotPialSurf('NiAs',cfg);


