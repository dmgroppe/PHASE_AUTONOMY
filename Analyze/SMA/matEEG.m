
function [d] = matEEG(eegRec,work)
global d
global S %our form data 
global eegToImport
global finished
finished=0;

% DEFINITIONS %%%%%%%%%%%%%%%%
d.intLen=2; %default interval lenght in the view
d.triggersTTL=0;
if ~exist('eegRec','var'), eegRec= []; end
if ~exist('work','var'), work.isWorkSpace=0; end


% if we don't pass a workspace inaa, we are starting a new one!
if nargin ==1,work.isWorkspace=0; end
if nargin ==2, eegToImport=eegRec;end % we use this array also to import it into existing workspace


if (work.isWorkSpace==1)
    d=work;
    d.isWorkSpace=1;
    % d.recFreq=eegRec.srate;
    % now convert the time triggers to the sample points trigs
    for i=1:d.nEvents-1
       d.triggGlob(i)=int64(d.triggTime(i)*d.recFreq);
    end
    d.triggGlob(d.nEvents)=length(d.recData(1,:));
    d.timeData=0:1.0/d.recFreq:1.0/d.recFreq*d.tickLen;
else
    d.isWorkSpace=1;
    [d.chanCnt,d.tickLen]=size(eegRec);
    % now if the events dont exist, try seeing if you can extract them from the
    % last line of eegRec
    d.nEvents=0;
    haveEvInfo=0;
    
    noEvs=0;
    %if ~exist('evnts','var')
   %    noEvs=1;
    %    evnts=[];
  % end
    %[dum,d.nEvents]=size(evnts);
    [t1 t2]=size(eegRec.event);
    if(t1==0)
        noEvs=1;
        d.nEvents=0;
        d.eventType=-1;
    else
        d.triggGlob=cell2mat({eegRec.event(:).latency});
        d.eventType=cell2mat({eegRec.event(:).type});
        d.triggTime=d.triggGlob/d.recFreq;
        [dum,d.nEvents]=size(d.triggGlob);
        d.triggTime(d.nEvents)=d.tickLen/d.recFreq;
    end
    
    if(d.nEvents==1)
        noEvs=1;
        d.nEvents=0;
    end
    %if ~exist('freq','var'), freq= 100; end
    
    d.recFreq=eegRec.srate;
    d.ampMult=1.0;
    d.recData=eegRec.data; % var passing
    

    [d.chanCnt,d.tickLen]=size(d.recData);
    d.chan=1;
    d.epoc=1;


    if(d.recData(d.chanCnt,1)==0)
        haveEvInfo=1;
    end
    % lets check if this is binary denoted epochs
    if(noEvs==1)
       d.triggersTTL=0;
       for i=1:d.tickLen
          if(d.recData(d.chanCnt,i)==1)
              d.nEvents=d.nEvents+1;
              d.triggGlob(d.nEvents)=i;
              d.triggTime(d.nEvents)=i/d.recFreq;
          end
       end
       d.nEvents=d.nEvents+1;
        d.triggGlob(d.nEvents)=d.tickLen;
              d.triggTime(d.nEvents)=d.tickLen/d.recFreq;
    end
    % we define the very last event as the end of the recs
    isTTL=0;
    if(d.nEvents>2)
        d.nEvents=d.nEvents+1;
        d.triggGlob(d.nEvents)=d.tickLen;
    else
        % if we didn't find any events by looking for 1s and 0s, lastly,
        % lets check if this is TTL pulse denoted
        isTTL=1;
    end    
    
    if(isTTL==1)
        extractTTL();
        d.triggersTTL=1;        
    end

    % go through all the channels and epochs and null the selections

    for p=1:d.chanCnt
        for e=1:d.nEvents+2
            
            % init the selections
            d.sl(p,e).ne=0; % set the num of sels per epoc to 0
            d.sl(p,e).ev(1:20,1:2)=0; % set the sels to 0            
            d.valEp(p,e)=1;
            d.baseEp(p,e)=0;
            d.expEp(p,e)=0;
        end
    end
    d.timeData=0:1.0/d.recFreq:1.0/d.recFreq*d.tickLen;
end
d.artSearch=-1;
S.fh = figure('units','pixels',...
              'position',[300 300 990 350],...
              'menubar','none',...
              'name','matEEG',...
              'numbertitle','off',...
              'resize','off');
          
          
%create the labels
S.lch = uicontrol('style','text',...    
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[0 150 100 30],...
                 'fonts',10,...
                 'str','Channel');
%epoch             
S.lep = uicontrol('style','text',...
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[130 150 100 30],...
                 'fonts',10,...
                 'str','Epoch');
%amplitude
S.am= uicontrol('style','text',...
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[260 150 100 30],...
                 'fonts',10,...
                 'str','Amplitude');
%valid

S.val= uicontrol('style','text',...
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[430 150 100 30],...
                 'fonts',10,...
                 'str','Valid Epoch?');

             
             
%edit boxes
S.ech = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[80 163 45 20],...
                 'String','1',...
                    'fonts',10);
             
S.eep = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[200 163 45 20],...
                 'String','1',...
                 'fonts',10);
S.eam = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[345 163 45 20],...
                 'String','1',...
                 'fonts',10);

             
             
% now the buttons
%create the updown for d.chan
S.bcu = uicontrol('style','push',...
                 'units','pixels',...
                 'BackgroundColor',[204/255 204/255 204/255],...ff
                 'position',[130 173 12 12],...
                 'fonts',10,...
                 'str','+');
S.bcd = uicontrol('style','push',...
                 'units','pixels',...
                 'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[130 161 12 12],...
                 'fonts',10,...
                 'str','-');
S.beu = uicontrol('style','push',...
                 'units','pixels',...
                 'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[249 173 12 12],...
                 'fonts',10,...
                 'str','+');
S.bed = uicontrol('style','push',...
                 'units','pixels',...
                 'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[249 161 12 12],...
                 'fonts',10,...
                  'str','-');
 S.pl = axes( 'units','pix',...
                 'position',[0 200 990 150],...
                 'Box','off',...
                 'ALimMode','manual',...
                  'XLim',[0,200000],...
                  'HitTest','off',...
                 'TickLength', [0,0],...
                 'XTick',[],...
                 'XColor',get(S.fh,'color'),...                
                 'fontsize',10);    
             
             
S.bau = uicontrol('style','push',...
                 'units','pixels',...
                 'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[392 173 12 12],...
                 'fonts',10,...                 
                 'str','+');
S.bad = uicontrol('style','push',...
                 'units','pixels',...
                 'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[392 161 12 12],...
                 'fonts',10,...
                  'str','-');
 %val toggle
S.buttval= uicontrol('style','checkbox',...
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                  'Value',1,...
                 'position',[530 157 100 30]);

% now the status text
S.stt = uicontrol('style','text',...    
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[560 150 400 30],...
                 'fonts',10,...                
                'HorizontalAlignment','left',...
                 'str','X: Start: End: Len:');

% add select baseline/experiment checks
S.baseText= uicontrol('style','text',...
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[20 100 100 30],...
                 'fonts',10,...
                 'HorizontalAlignment','left',...
                 'str','Epoc(s)');

             
S.expText= uicontrol('style','text',...
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[20 70 100 30],...
                 'fonts',10,...
                 'HorizontalAlignment','left',...
                 'str','Normalize to epoch(s)');
             
       
         
%S.baseTog= uicontrol('style','checkbox',...
%                 'units','pixels',...
%                  'BackgroundColor',[204/255 204/255 204/255],...
%                  'Value',0,...
%                 'position',[100 108 100 30]);

%S.expTog= uicontrol('style','checkbox',...
%                 'units','pixels',...
%                  'BackgroundColor',[204/255 204/255 204/255],...
%                  'Value',0,...
%                 'position',[100 78 30 30]);




S.epocList = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[100 112 200 20],...
                 'String','',...
                 'fonts',10);
             
             
S.chanList = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[400 112 200 20],...
                 'String','',...
                 'fonts',10);
% add select baseline/experiment checks
S.chansnorm = uicontrol('style','text',...
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                 'position',[310 100 60 30],...
                 'fonts',10,...
                 'HorizontalAlignment','left',...
                 'str','Chan(s)');

S.normList = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[100 82 200 20],...
                 'String','',...
                 'fonts',10);

             
             
% comp spectra
 S.compSpectra = uicontrol('style','push',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[20 20 140 20],...
     'fonts',10,...
      'str','Compute Spectra');
  
     S.timfr = uicontrol('style','push',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[20 50 140 20],...
     'fonts',10,...
      'str','Time Freq spec');
    
   S.avep = uicontrol('style','push',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[180 50 140 20],...
     'fonts',10,...
      'str','Avg Epocs');
  
   S.remEpocMean = uicontrol('style','push',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[180 20 140 20],...
     'fonts',10,...
      'str','Remove Epoc Mean');

  %new window with epoch Properties
     S.epPropButt = uicontrol('style','push',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[840 10 140 20],...
     'fonts',10,...
      'str','Epoch Properties');
  S.epPropFig = figure('units','pixels',...
              'position',[300 300 300 200],...
              'menubar','none',...
              'visible','off',...
              'name','Epoch Properties',...
              'numbertitle','off',...
              'resize','on');
  % draw in the options
       S.epOffset = uicontrol(S.epPropFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 170 140 20],...
     'fonts',10,...
      'HorizontalAlignment','left',...
      'str','Epoch Offset(ms):');
  
     S.epFixLen = uicontrol(S.epPropFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 140 140 20],...
     'fonts',10,...
      'HorizontalAlignment','left',...
      'str','Epoch Max len.(ms):');  
        
     S.OffsetInp = uicontrol(S.epPropFig,'style','edit',...
     'units','pixels',...
     'position',[140 170 50 20],...
     'fonts',10,...
      'str','0');
  
     S.maxEpLen = uicontrol(S.epPropFig,'style','edit',...
     'units','pixels',...
     'position',[140 140 50 20],...
     'fonts',10,...
      'str','0');
  
      S.epOK = uicontrol(S.epPropFig,'style','push',...
     'units','pixels',...
     'position',[120 20 50 20],...
     'fonts',10,...
      'str','OK');
  % ///////////////////////////////////////////////
  %            Import Epochs dialog
  %//////////////////////////////////////////////
  
    %new window with epoch Properties
  S.impEpochButton = uicontrol(S.fh ,'style','push',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[840 40 140 20],...
     'fonts',10,...
      'str','Import Epochs');
  S.importEpochFig= figure('units','pixels',...
              'position',[300 300 300 200],...
              'menubar','none',...
              'visible','off',...
              'name','Import Epochs',...
              'numbertitle','off',...
              'resize','on');
          
  % label 
      S.ep2imp = uicontrol(S.importEpochFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 110 140 20],...
     'fonts',10,...
      'HorizontalAlignment','left',...
      'str','Epochs to import:');
    
        
     S.epList = uicontrol(S.importEpochFig,'style','edit',...
     'units','pixels',...
     'position',[140 110 50 20],...
     'fonts',10,...
      'str','');
  
  
  
      S.processImport = uicontrol(S.importEpochFig,'style','push',...
     'units','pixels',...
     'position',[60 170 190 20],...
     'fonts',10,...
      'str','Find Epochs in imported EEG');
  
  
      S.previewImp = uicontrol(S.importEpochFig,'style','push',...
     'units','pixels',...
     'position',[60 140 190 20],...
     'fonts',10,...
      'str','Preview Imported Epochs');  
  
      S.mergeEps = uicontrol(S.importEpochFig,'style','push',...
     'units','pixels',...
     'position',[60 70 190 20],...
     'fonts',10,...
      'str','Merge Epochs to Wkspc');
  
  
      S.epImpOK = uicontrol(S.importEpochFig,'style','push',...
     'units','pixels',...
     'position',[120 20 50 20],...
     'fonts',10,...
      'str','OK');
  
  
% ///////////////////////////////////////////
%  The export epoch window
  

%...
  S.expEpochButton = uicontrol(S.fh ,'style','push',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[840 70 140 20],...
     'fonts',10,...
      'str','Export Epochs');
  
  S.exportEpochFig= figure('units','pixels',...
              'position',[300 300 300 200],...
              'menubar','none',...
              'visible','off',...
              'name','Export Epochs',...
              'numbertitle','off',...
              'resize','on');

  % by epoch number
  S.ep2ex = uicontrol(S.exportEpochFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 180 140 20],...
     'fonts',10,...
      'HorizontalAlignment','left',...
      'str','Epochs to export:');
  
  
  S.ep2exbn = uicontrol(S.exportEpochFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 160 140 20],...
     'fonts',10,...
      'HorizontalAlignment','right',...
      'str','- by number: ');
  
  
  S.ep2exbt = uicontrol(S.exportEpochFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 135 140 20],...
     'fonts',10,...
      'HorizontalAlignment','right',...
      'str','- by type: ');
  
  
    S.igsels = uicontrol(S.exportEpochFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 100 140 20],...
     'fonts',10,...
      'HorizontalAlignment','right',...
      'str','Ignore tagged data? ');
  
      S.mld= uicontrol(S.exportEpochFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 75 140 20],...
     'fonts',10,...
      'HorizontalAlignment','right',...
      'str','Min epoch length: ');
  
    
      S.pdd= uicontrol(S.exportEpochFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 50 140 20],...
     'fonts',10,...
      'HorizontalAlignment','right',...
      'str','Pad data by x ms: ');
  
  % the list boxes

   S.epExpNumList = uicontrol(S.exportEpochFig,'style','edit',...
     'units','pixels',...
     'position',[160 162 100 20],...
     'fonts',10,...
      'str','');
  
   S.epExpTypeList= uicontrol(S.exportEpochFig,'style','edit',...
     'units','pixels',...
     'position',[160 137 100 20],...
     'fonts',10,...
      'str','');
  
  
     S.epExpMinLen= uicontrol(S.exportEpochFig,'style','edit',...
     'units','pixels',...
     'position',[160 77 50 20],...
     'fonts',10,...
      'str','0');
  
     S.epPadlen= uicontrol(S.exportEpochFig,'style','edit',...
     'units','pixels',...
     'position',[160 50 50 20],...
     'fonts',10,...
      'str','0');
     S.epPadlenEnd= uicontrol(S.exportEpochFig,'style','edit',...
     'units','pixels',...
     'position',[220 50 50 20],...
     'fonts',10,...
      'str','0');
     %val toggle
     
     S.ignoreTags= uicontrol(S.exportEpochFig,'style','checkbox',...
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                  'Value',1,...
                 'position',[160 98 100 30]);
     % save as
     S.saveasButt = uicontrol(S.exportEpochFig,'style','push',...
     'units','pixels',...
     'position',[10 20 120 20],...
     'fonts',10,...
      'str','Save as ->');  
        
     S.expEpVarName= uicontrol(S.exportEpochFig,'style','edit',...
     'units','pixels',...
     'position',[150 20 110 20],...
     'fonts',10,...
      'str','');
  


% ///////////////////////////////////////////
%   The artifact... window


  S.artifactButton = uicontrol(S.fh ,'style','push',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[680 70 140 20],...
     'fonts',10,...
      'str','Artifacts...');
  
  S.artifactFig= figure('units','pixels',...
              'position',[300 300 180 200],...
              'menubar','none',...
              'visible','off',...
              'name','Artifacts...',...
              'numbertitle','off',...
              'resize','on');
   % find artifacts
      S.findArtButton = uicontrol(S.artifactFig,'style','push',...
     'units','pixels',...
     'position',[10 140 120 20],...
     'fonts',10,...
      'str','Find Artifacts');  
  
    % list artifacts
      S.listArtButton = uicontrol(S.artifactFig,'style','push',...
     'units','pixels',...
     'position',[10 90 120 20],...
     'fonts',10,...
      'str','List Artifacts');  
  
   % auto reject?

    S.autrj = uicontrol(S.artifactFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 112 140 20],...
     'fonts',10,...
      'HorizontalAlignment','left',...
      'str','Autoreject? ');
 
  
      
    S.alll = uicontrol(S.artifactFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 170 140 20],...
     'fonts',10,...
      'HorizontalAlignment','left',...
      'str','Alpha for reject: ');
  
      S.rejAlpha= uicontrol(S.artifactFig,'style','edit',...
     'units','pixels',...
     'position',[120 173 50 20],...
     'fonts',10,...
      'str','0.05');
  
  
      S.autorejchk= uicontrol(S.artifactFig,'style','checkbox',...
                 'units','pixels',...
                  'BackgroundColor',[204/255 204/255 204/255],...
                  'Value',1,...
                 'position',[100 112 100 25]);

  
    S.listArt= figure('units','pixels',...
              'position',[300 100 400 800],...
              'menubar','none',...
              'visible','off',...
              'name','Artifacts List',...
              'numbertitle','off',...
              'resize','on');
          
   S.artListLabel = uicontrol(S.listArt,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 10 350 780],...
     'fonts',10,...
      'HorizontalAlignment','left',...
      'str','Test');
 
  
  % ////////////////////////////
  % list epochs
  
  
    S.epochInfoButton = uicontrol(S.fh ,'style','push',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[680 38 140 20],...
     'fonts',10,...
      'str','Epoch List');
  
  S.epochListFig= figure('units','pixels',...
              'position',[300 100 400 800],...
              'menubar','none',...
             'visible','off',...
              'name','Epoch List',...
              'numbertitle','off',...
              'resize','on');
     S.epListLabel = uicontrol(S.epochListFig,'style','text',...
     'units','pixels',...
     'BackgroundColor',[204/255 204/255 204/255],...
     'position',[10 10 350 780],...
     'fonts',7,...
      'HorizontalAlignment','left',...
      'str','Test');
  

  
  
  % multichannel view
  
  
  S.allChans= figure('units','pixels',...
              'position',[400 100 990 900],...
                'Color','w',...         
                'menubar','none',...
              'name','All Channel View',...
              'numbertitle','off',...
              'resize','off');
          
  S.plAll = axes( 'Parent', S.allChans,'units','pix',...
                 'position',[30 0 990 900],...
                  'Box','off',...
                 'ALimMode','manual',...
                  'XLim',[0,200000],...
                  'HitTest','off',...
                 'TickLength', [0,0],...
                 'XTick',[],...
                 'XColor',get(S.fh,'color'),...                
                 'fontsize',10); 
  



  % now the callbacks


set(S.bcu,'callback',{@inc_chan,S});
set(S.bcd,'callback',{@dec_chan,S});

set(S.beu,'callback',{@inc_epoch,S});
set(S.bed,'callback',{@dec_epoch,S});

set(S.bau,'callback',{@inc_amp,S});
set(S.bad,'callback',{@dec_amp,S});
set(S.buttval,'callback',{@toggleVal,S});

%set(S.baseTog,'callback',{@toggleBase,S});
%set(S.expTog,'callback',{@toggleExp,S});
set(S.compSpectra,'callback',{@compSpectra,S});
set(S.timfr,'callback',{@compTimF,S});
set(S.remEpocMean,'callback',{@removeNoiseTimeDomain,S});
set(S.avep,'callback',{@avgEps,S});
set(S.epPropButt,'callback',{@epPropWind,S});
set(S.impEpochButton,'callback',{@imEpWind,S});
set(S.expEpochButton,'callback',{@exEpWind,S});
set(S.artifactButton,'callback',{@artBut,S});


set(S.fh,'KeyPressFcn',{@keyPresses,S});

set(S.fh,'WindowButtonMotionFcn',{@mouseMv,S});
set(S.fh,'CloseRequestFcn',{@figCls,S});

%edit box callbacks

set(S.ech,'callback',{@edch,S});
set(S.eep,'callback',{@edep,S});
set(S.epOK ,'callback',{@setEpOpt,S});
set(S.epImpOK,'callback',{@setImpOpt,S});

set(S.previewImp ,'callback',{@plotImpoch,S});   
set(S.processImport ,'callback',{@findEps,S});   
set(S.mergeEps ,'callback',{@mergeEpochs,S});  

%export epoch button

set(S.saveasButt ,'callback',{@saveEpochs,S});  
set(S.findArtButton,'callback',{@findArtifacts,S});  
set(S.artifactFig,'ButtonDownFcn',{@arf,S});  
set(S.exportEpochFig,'ButtonDownFcn',{@exf,S}); 
set(S.listArt,'ButtonDownFcn',{@larf,S}); 

set(S.listArtButton,'callback',{@larv,S});  


set(S.epochListFig,'ButtonDownFcn',{@eprf,S}); 

set(S.epochInfoButton,'callback',{@epin,S});  





              
%set(S.pl,'ButtonDownFcn',@dragSelectionRect);

%set([S.pop,S.ed],{'callback'},{{@pop_call,S};{@ed_call,S}}); % Set callback
% now set the x axis
%for j=0:d.tickLen
%    d.timeData(j+1)=(1.0/d.recFreq*j);
%end

%do prep here, normalize

%for p=1:d.chanCnt
 %   for k=1:d.nEvents-1
  %    st=d.triggGlob(k);
  %    en=d.triggGlob(k+1);
  %    d.recData(p,st:en)=d.recData(p,st:en)/max(d.recData(p,st:en));
 %   end    
%end
d.offs=0;
d.maxLen=0;

plotEpoch(S);

for i=1:100000
    pause(1);
    if(finished==1)
        break;
    end
end    





%increase the channel callback
function [] = inc_chan(varargin)
global d
global S
d.chan=d.chan+1;
if(d.chan>d.chanCnt)
    d.chan=d.chanCnt;
end
set(S.ech,'String',d.chan)
tt=get(S.importEpochFig ,'visible');
if(strcmp(tt,'on'))
   plotImpoch();
else
    plotEpoch();
end
t=findobj('name','specy');
if(t>1)   % if we have the spectra up, redraw it
    compSpectra();
end
    
%increase the channel callback
function [] = dec_chan(varargin)
global d
global S
d.chan=d.chan-1;
if (d.chan<=1)
    d.chan=1;
end
set(S.ech,'String',d.chan)
tt=get(S.importEpochFig ,'visible');
if(strcmp(tt,'on'))
   plotImpoch();
else
    plotEpoch();
end
t=findobj('name','specy');
if(t>1)   % if we have the spectra up, redraw it
    compSpectra(1);
end



%increase the channel callback
function [] = inc_epoch(varargin)
global d
global S
d.epoc=d.epoc+1;
if(d.epoc>=d.nEvents)
    d.epoc=d.nEvents-1;
end
set(S.eep,'String',d.epoc)
tt=get(S.importEpochFig ,'visible');
if(strcmp(tt,'on'))
   plotImpoch();
else
    plotEpoch();
end
t=findobj('name','specy');
if(t>1)   % if we have the spectra up, redraw it
    compSpectra();
end

%increase the channel callback
function [] = dec_epoch(varargin)
global d
global S
d.epoc=d.epoc-1;
if (d.epoc<=1)
    d.epoc=1;
end
set(S.eep,'String',d.epoc)
tt=get(S.importEpochFig ,'visible');
if(strcmp(tt,'on'))
   plotImpoch();
else
    plotEpoch();
end
t=findobj('name','specy');
if(t>1)   % if we have the spectra up, redraw it
    compSpectra();
end

%increase the channel callback
function [] = inc_amp(varargin)
global d
global S

d.ampMult=d.ampMult*1.5;
set(S.eam,'String',d.ampMult)
tt=get(S.importEpochFig ,'visible');
if(strcmp(tt,'on'))
   plotImpoch();
else
    plotEpoch();
end

%increase the channel callback

function [] = dec_amp(varargin)
global d
global S
d.ampMult=d.ampMult/1.5;
if(d.ampMult<0)
    d.ampMult=0;
end
set(S.eam,'String',d.ampMult)
tt=get(S.importEpochFig ,'visible');
if(strcmp(tt,'on'))
   plotImpoch();
else
    plotEpoch();
end


function [] = edch(varargin)
global d
global S
d.chan=str2num(get(S.ech,'str'));
plotEpoch(S);

function [] = edep(varargin)
global d
global S
d.epoc=str2num(get(S.eep,'str'));
plotEpoch(S);

function [] = plotEpoch(varargin)
global d
global S

figure(S.fh);

%d.epoc holds the value of the current trigg

stPl=d.triggGlob(d.epoc);  
enPl=d.triggGlob(d.epoc+1);

if(d.maxLen>0)

    if(enPl-stPl>d.recFreq/1000*d.maxLen)
        enPl=stPl+d.recFreq/1000*d.maxLen;
    end
end
        
    
if(d.offs>0)
    if(stPl>(d.offs*d.recFreq/1000))
      stPl=stPl-(d.offs*d.recFreq/1000);
    end
end
if(d.epoc>=58)
    d.epoc=d.epoc;
end
x=d.timeData(stPl:enPl);

y=d.recData(d.chan:d.chan,stPl:enPl)*d.ampMult;

d.timeData(stPl:enPl);
h=gca;
tmpY=y-mean(y);
cl='b';

if(d.baseEp(d.chan,d.epoc)==1)    
    cl='g';
end

if(d.expEp(d.chan,d.epoc)==1)
    cl='m';
end


if(d.valEp(d.chan,d.epoc)==0)
    cl='k';
end
plot(x,tmpY,cl);


% if we have selected stuff here, then plot it in red
if(d.sl(d.chan,d.epoc).ne>0)
    
    hold on;
    for b=1: d.sl(d.chan,d.epoc).ne
        st=(d.sl(d.chan,d.epoc).ev(b,1))*d.recFreq-stPl;
        en=(d.sl(d.chan,d.epoc).ev(b,2))*d.recFreq-stPl;
        if(en+stPl>enPl) en=enPl-stPl;end
        if(st<1),st=1;end
        lp= plot(x(st:en),tmpY(st:en),'r');
        set(lp,'LineWidth',1.5);
    end  
    
    hold off;
end

% if we have ttlMarkers, show the position of the 2nd ttl marker
if(d.triggersTTL==1)
    
    hold on;
         
        st=d.ttlMarker(d.epoc).start*d.recFreq-stPl;
        if(st<1),st=1;end
        en=d.ttlMarker(d.epoc).end*d.recFreq-stPl;    
        lp= plot(x(st:en),tmpY(st:en));
        if(d.epoc>80)
            d.epoc=d.epoc;
        end
        set(lp,'LineWidth',1.5);
        set(lp,'Color',[1 0.5 0.2]);
    hold off;
end




set(h,'YTick',[])
set(h,'XTick',[])
set(h,'XLim',[d.timeData(stPl:stPl),d.timeData(stPl:stPl)+d.intLen])
set(h,'YLim',[-1,1])

set(h,'Box','off')
set(h,'XColor',get(S.fh,'color'))
set(gca,'ButtonDownFcn',{@dragSelectionRect});

%set the checkboxes
set(S.buttval,'Value',d.valEp(d.chan,d.epoc));


% if we have the all channels epoch list vis
allChVis=get(S.allChans,'Visible');
if(allChVis=='on')
plotAllEpochs();    
    
end
%set(S.baseTog,'Value',d.baseEp(d.chan,d.epoc));
%set(S.expTog,'Value',d.expEp(d.chan,d.epoc));



function [] = toggleVal(varargin)
global S 
global d
d.valEp(d.chan,d.epoc)=get(S.buttval,'Value');
plotEpoch()


function [] = toggleBase(varargin)
global S
global d
d.baseEp(:,d.epoc)=get(S.baseTog,'Value');
plotEpoch()

function [] = toggleExp(varargin)
global S
global d
d.expEp(:,d.epoc)=get(S.expTog,'Value');
plotEpoch()

function [] = keyPresses(varargin)
global S

global d
p = get(S.fh, 'CurrentCharacter');
t=double(p)

%switch
if(t==30) % up
    inc_chan();
end
if (t==31)
    dec_chan();
end 
if (t==29)
    inc_epoch();
end 
if (t==28)    
    dec_epoch();
end 
if (t==113)
    inc_amp();
end 
if (t==97)    
    dec_amp();
end 
%c=clear the sel
if (t==99)
    d.sl(d.chan,d.epoc,1)=0;
    plotEpoch();
end 

%decrease interval len
if (t==93)
    d.intLen=d.intLen*0.8;
    plotEpoch();
end

if (t==91)
    d.intLen=d.intLen*1.6;
    plotEpoch();
end

if (t==13)
    stPl=d.triggGlob(d.epoc);  
    enPl=d.triggGlob(d.epoc+1);
    
   % powerSpecAllChanAvg(d.recData(d.chan,stPl:enPl),d.recFreq,1);
end
%v toggle validity
if (t==118)    t=get(S.buttval,'Value');
    t=1-t;
    set(S.buttval,'Value',t);
    d.valEp(d.chan,d.epoc)=t;
    t=findobj('name','specy');
    if(t>1)   % if we have the spectra up, redraw it
        compSpectra(1);
    end
    plotEpoch();
end 


%w toggle validity...of all chans for this epoc
if (t==119)   
    for i=1:d.chanCnt
        t=d.valEp(i,d.epoc);
        t=1-t;
        set(S.buttval,'Value',t);
        d.valEp(i,d.epoc)=t;        
    end
    t=findobj('name','specy');
    if(t>1)   % if we have the spectra up, redraw it
        compSpectra(1);
    end
    plotEpoch();
end 

%x is experimental
if (t==120)   
    t=get(S.expTog,'Value');
    t=1-t;
    set(S.expTog,'Value',t);
    d.expEp(:,d.epoc)=t;
    plotEpoch();
end
%z is baseline
if (t==122)
    t=get(S.baseTog,'Value');
    t=1-t;
    set(S.baseTog,'Value',t);
    d.baseEp(:,d.epoc)=t;
    plotEpoch();
end



function [] = dragSelectionRect(varargin)
global S
global d


point1 = get(S.pl,'CurrentPoint');    % button down detected
finalRect = rbbox;
% return figure units
point2 = get(S.pl,'CurrentPoint');    % button up detected
x1=point1(1)
x2=point2(2)
if(x1>x2)
    t=x1;
    x1=x2;
    x2=t;
end
if(x1==x2)
    %clear the selection
    % we need to cycle through all the selections to find one in this
    % d.epoc frame
    d.sl(d.chan,d.epoc,1)=0;
    d.sl(d.chan,d.epoc,2)=0;     
else    

    
    %check if dragged passed epoc Borders and cap
    if(x1<d.triggGlob(d.epoc)/d.recFreq)
        x1=d.triggGlob(d.epoc)/d.recFreq;
    end
    if(x2>d.triggGlob(d.epoc+1)/d.recFreq)
        x2=d.triggGlob(d.epoc+1)/d.recFreq;
    end
    ind=d.sl(d.chan,d.epoc).ne;   
    
    %lets check if we are selecting and already selected area
        % if so we need to cancel/clear that selection
        isErase=0;
     for l=1:ind
        s= d.sl(d.chan,d.epoc).ev(l,1);
        e= d.sl(d.chan,d.epoc).ev(l,2);
        if(s>x1 && s<x2)|| (e>x1 && e<x2)
            for p=l:ind-1
                d.sl(d.chan,d.epoc).ev(p,1)=d.sl(d.chan,d.epoc).ev(p+1,1);
                d.sl(d.chan,d.epoc).ev(p,2)=d.sl(d.chan,d.epoc).ev(p+1,2);
            end
            isErase=1;
            ind=ind-1;
            d.sl(d.chan,d.epoc).ne=d.sl(d.chan,d.epoc).ne-1;
        end
     end
     if(isErase==0)
        d.sl(d.chan,d.epoc).ne=d.sl(d.chan,d.epoc).ne+1;
        
        ind=d.sl(d.chan,d.epoc).ne;   
        d.sl(d.chan,d.epoc).ev(ind,1)=x1;
        d.sl(d.chan,d.epoc).ev(ind,2)=x2;
     end
    plotEpoch();
end



function []= mouseMv(varargin)
global S
global d
 p = get(S.pl,'CurrentPoint');
 if(p(1,3)==1)
    x=p(1,1);
    k='';
    set(S.stt,'str','');
    stPl=d.triggGlob(d.epoc);     
    k=sprintf('CurrX:%g(%7.3fs)\t OverallX:%g(%7.3fs)',...
    round(x*d.recFreq)-stPl,x-(stPl/d.recFreq), round(x*d.recFreq),x);
    set(S.stt,'str',k);
 end
        
% plot the spectra for the selected chans

function []= removeNoiseTimeDomain(varargin)
global S
global d


% go through all the epocs
typEp=str2num(get(S.epocList,'str'));

for i=1:length(typEp)
    ep=typEp(i);
    for o=d.triggGlob(ep):d.triggGlob(ep+1)
        nz(o)=mean(d.recData(1:d.chanCnt,o));
    end
    %now go through every channel subtracting the noise
    for p=d.triggGlob(ep):d.triggGlob(ep+1)
       for z=1:d.chanCnt
          d.recData(z,p)=d.recData(z,p)-nz(p);    
       end
    end
end


function []= avgEps(varargin)
global S
global d


% go through all the epocs
typEp=str2num(get(S.epocList,'str'));

% go through it chan by chan
for i=1:d.chanCnt
    % go through all the epocs in interest
    for k=1:length(typEp)
        ep=typEp(k);    
        ar(k,:)=d.recData(i,d.triggGlob(ep):d.triggGlob(ep+1));        
    end
    for k=1:length(typEp)
        ep=typEp(k);    

        for j=1:d.triggGlob(ep+1)-d.triggGlob(ep)+1
            mn(j)=mean(ar(:,j));
        end
    end
    for k=1:length(typEp)
        ep=typEp(k);    
        d.recData(i,d.triggGlob(ep):d.triggGlob(ep+1))=mn; 
    end
end


function [] = compSpectra(varargin)
global S
global d


% once we select to compute spectra, need to obtain data from 
% S.epocList and S.normList
ind=1;

typEp=str2num(get(S.epocList,'str'));
typNm=str2num(get(S.normList,'str'));
%for i=1:d.chanCnt-1
%    ind=1;
%    for o=d.triggGlob(typEp(1)):d.triggGlob(typEp(1)+1)
%       baseAccum(ind)=d.recData(i,o);       
%       ind=ind+1;      
%    end
%    baseAccum=squeeze(baseAccum);
%    oddFTT=powerSpecAllChanAvg(baseAccum,d.recFreq,1);
%    oddFTT=squeeze(oddFTT);
%    k(i,:)=oddFTT(2,:);
%end

%for i=1:d.chanCnt
%    ind=1;
%    for o=d.triggGlob():d.triggGlob(typEp(1)+1)
%      baseAccum(ind)=d.recData(i,o);       
%      ind=ind+1;      
%    end
%    baseAccum=squeeze(baseAccum);
%    oddFTT=powerSpecAllChanAvg(baseAccum,d.recFreq,1);
%    oddFTT=squeeze(oddFTT);
%    k(i,:)=oddFTT(2,:);
%end

%t=length(oddFTT(2,:));
%for j=1:t
%   avSpec(j)=mean(k(:,j));    
%end
%baseAccum=squeeze(baseAccum);
%oddFTT=powerSpecAllChanAvg(baseAccum,d.recFreq,1);
%oddFTT=squeeze(oddFTT);


%adhoc all 4eps

  %  ss=d.triggGlob(3);
  %  ee=d.triggGlob(4);
  %  ps1=powerSpecAllChanAvg(d.recData(d.chan,ss:ee) ,d.recFreq,1);
  %  ps1=squeeze(ps1);
  %  figure(311); 
%    plot(ps1(1,:),log10(ps1(2,: )),'r');  
%    xlabel('Frequency (Hz)')
%    ylabel('|Y(f)|')
%    set(gca,'XLim',[2,250]);
    
 %   return;
% glue together all the selected base epocs

    ind=1; % index in the array

    for i=1:length(typEp)
        ep=typEp(i);
        for o=d.triggGlob(ep):d.triggGlob(ep+1)
           baseAccum(ind)=d.recData(d.chan,o);       
           ind=ind+1;      
        end
    end
    baseAccum=squeeze(baseAccum);
    expFTT=powerSpecAllChanAvg(baseAccum,d.recFreq,1);
    expFTT=squeeze(expFTT);
    expFTT(2,:)=log10(expFTT(2,:));
    expFTT(3,:)=log10(expFTT(3,:));
    expFTT(4,:)=log10(expFTT(4,:));



    baseAccum=0;
    ind=1;
    for i=1:length(typNm)
        ep=typNm(i);
        for o=d.triggGlob(ep):d.triggGlob(ep+1)
           baseAccum(ind)=d.recData(d.chan,o);       
           ind=ind+1;      
        end
    end
    baseAccum=squeeze(baseAccum);
    baseFTT=powerSpecAllChanAvg(baseAccum,d.recFreq,1);
    baseFTT(2,:)=log10(baseFTT(2,:));
    baseFTT(3,:)=log10(baseFTT(3,:));
    baseFTT(4,:)=log10(baseFTT(4,:));


    t=findobj('name','filly');
    if(t>1)    
        figure(t);
    else
        figure('name','filly');
    end
    hold off;
    jbfill(baseFTT(1,:),(baseFTT(3,:)),(baseFTT(4,:)),'b','b',0,0.2);
    hold on;
    plot(baseFTT(1,:),(baseFTT(2,:)),'b');
    hold off;
    jbfill(baseFTT(1,:),(expFTT(3,:)),(expFTT(4,:)),'r','r',1,0.2);
    hold on;
    plot(baseFTT(1,:),(expFTT(2,:)),'r');
    hold off;
    set(gca,'XLim',[3,250]);
    set(gca,'YLim',[-5,0.5]);
    %jbfill(baseFTT(1,:),(baseFTT(3,:)),(baseFTT(4,:)),'b','b',1,0.2);
    %baseFTT=baseFTT/max(baseFTT);
    t=findobj('name','filly');
    
t=findobj('name','specy');
if(t>1)    
    figure(t);
else
    figure('name','specy');
end
              
plot(baseFTT(1,:),(baseFTT(2,:)),'g');
hold on;   
plot(baseFTT(1,:),(baseFTT(3,:)),'g');
plot(baseFTT(1,:),(baseFTT(4,:)),'g');
set(gca,'XLim',[2,250]);
set(gca,'XLim',[2,250]);
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
set(gca,'XLim',[2,250]);
plot(baseFTT(1,:),(expFTT(2,:)),'m');
plot(baseFTT(1,:),(expFTT(3,:)),'m');
plot(baseFTT(1,:),(expFTT(4,:)),'m');

hold off;

% we can also plot the log10(exp/base)
a=baseFTT(2,:);
a=exp(a);
b=expFTT(2,:);
b=exp(b);

for i=1:length(b)
    c(i)=b(i)/a(i);
end
c=log10(c);
%c=c-mean(c);
c(:)=smooth(c(:),5);

%now the lower border


b=expFTT(3,:);
b=exp(b);
for i=1:length(b)
    cl(i)=b(i)/a(i);
end
cl=log10(cl);
cl(:)=smooth(cl(:),5);

%now the upper border


b=expFTT(4,:);
b=exp(b);
for i=1:length(b)
    cu(i)=b(i)/a(i);
end
cu=log10(cu);
cu(:)=smooth(cu(:),5);
    
t=findobj('name','loggy');
if(t>1)    
    figure(t);
else
    figure('name','loggy');
end

plot(baseFTT(1,1:250),(c(1:250)),'k');
hold on;
%plot(baseFTT(1,1:250),(cl(1:250)),'r');
%plot(baseFTT(1,1:250),(cu(1:250)),'b');
hold off;
xlabel('Frequency (Hz)')
ylabel('log10(exp/base)')
set(gca,'XLim',[2,200]);
%hold on;
%plot(baseFTT(1,1:200),d(1:200),'r');
%hold off;



tifrspec();

figure(S.fh);



% here we will plot the time frequency spectrogram

% here we will plot the time frequency spectrogram

function [] = tifrspec(varargin)
global S
global d

dataEEG=d.recData(d.chan,d.triggGlob(1):d.triggGlob(2));
[d3,p]=size(dataEEG);
Len=p;

T = 1/d.recFreq;                     
L = d.recFreq;                    
NFFT=d.recFreq;

f = d.recFreq/2*linspace(0,1,NFFT/2+1);

k= zeros (double(400),length(f));
ctr=0;
o=0;

windLen=1200;
windOverlap=0.40;
windLen=(windLen*d.recFreq/1000);

incr=windLen*(1-windOverlap);
maxl=Len-windLen-incr;
for j=1:incr:maxl
    ctr=ctr+1;
    y=dataEEG(j:j+windLen);
    wy=transpose(hann(length(y)));
    y=y.*wy;    
    [Pxx,Pxxc,f]=pmtm(y,6,windLen,d.recFreq,0.95);        
    Pxx=transpose(Pxx);
    k(ctr,1:length(Pxx))=(Pxx(:));            
end

for y=1:length(Pxx)
    z=squeeze(k(:,y));
    baseFTT(y)=mean(z(:)); %for this freq bin, sum across all winds
end



% now lets do the test/examining epoch
dataEEG=d.recData(d.chan,d.triggGlob(3):d.triggGlob(4));
[d3,p]=size(dataEEG);
Len=p;

k2= zeros (double(400),length(f));
ctr=0;
o=0;

maxl=Len-windLen-incr;
for j=1:incr:maxl
    ctr=ctr+1;
    y=dataEEG(j:j+windLen);
    wy=transpose(hann(length(y)));
    y=y.*wy;    
    [Pxx,Pxxc,f]=pmtm(y,6,windLen,d.recFreq,0.95);        
    Pxx=transpose(Pxx);
    k2(ctr,1:length(Pxx))=(Pxx(:));            
end


t=findobj('name','specTif');
if(t>1)    
    figure(t);
else
    figure('name','specTif');
end
for al=1:ctr
    for po=1:windLen/2+1
       k2(al,po)= log10(k2(al,po)/baseFTT(po));        
    end
    
end
%plot(f,(baseFTT));

%po=pcolor(f(1:windLen/2+1),1:ctr,k2(1:ctr,1:windLen/2+1));
%po=pcolor(k2(1:ctr,1:windLen/2+1));
%set(po,'edgecolor','none');
%set(gca,'XLim',[10,250]);
%xlabel('Frequency (Hz)')
%ylabel('log10(Pread/Prest)')
%colormap( jet);

axis xy








function [] =figCls(varargin)
global finished

finished=1;
delete(gcf);



function [] =extractTTL(varargin)
global d
global S
% ttl pulses are in the last channel of data as spikes of great amplitude
% to charactarize pulse sigs, go through 1/4 of data and find the largest
% delta between points and use 1/10 this value as the cuttoff for trigger
largestDelta=0;
for i=1:d.tickLen/4
    if(abs(d.recData(d.chanCnt,i+1)-d.recData(d.chanCnt,i))>largestDelta)
        largestDelta=abs(d.recData(d.chanCnt,i+1)-d.recData(d.chanCnt,i));
    end
end    
% now go through all the chans extracting the trigger stamps
cutOff=largestDelta/100;
ind=0;
fndFirst=0;
fndVeryFirst=0;

leeway=0; %the signals are not exactly straight, so we need to make sure
          % we dont pick up two triggers on where it is really just one
          
minEpochLenCutoff=0.160; % we will have a min of 120 ms before starting a new epoch
                         % otherwise we just grow the previous trigger end 


%it seems that the very first spike marks the begining of data not an epoch!
for i=1:d.tickLen-1
    if(leeway<=0)
        if(abs(d.recData(d.chanCnt,i+1)-d.recData(d.chanCnt,i))>cutOff)
            %lets see if this is very first spike
            if(fndVeryFirst==0)            
                fndVeryFirst=1;
                leeway=d.recFreq*0.015;
                veryFirstTime=i/d.recFreq;
            else
                %check if this is the first marker signal
                if(fndFirst==0)

                    
                    if(ind>1)
                        % if the prev epoch is long enough, start a new one
                      if(i/d.recFreq-d.ttlMarker(ind).end>minEpochLenCutoff)
                        ind=ind+1;
                        % we are only saving the first part of the wave             
                        fndFirst=1;
                        d.ttlMarker(ind).start=i/d.recFreq;
                        leeway=d.recFreq*0.015;
                        % if the new epoch is too short...we just extend
                        % the trigger.
                      else
                         
                          d.ttlMarker(ind).end=i/d.recFreq;
                          leeway=d.recFreq*0.015;
                          d.eventType(ind)=d.eventType(ind)+0.5;
                          d.triggGlob(ind)=i;
                          d.triggTime(ind)=i/d.recFreq;
                      end
                    else
                        ind=ind+1;
                        % we are only saving the first part of the wave             
                        fndFirst=1;
                        d.ttlMarker(ind).start=i/d.recFreq;
                        if(d.ttlMarker(ind).start-veryFirstTime < minEpochLenCutoff)
                            
                            d.ttlMarker(ind).end=d.ttlMarker(ind).start;
                            d.ttlMarker(ind).start=veryFirstTime;
                            d.eventType(ind)=1;
                            d.triggGlob(ind)=i;
                            d.triggTime(ind)=i/d.recFreq;
                            fndFirst=0;                            
                        end
                        leeway=d.recFreq*0.015;                         
                    end
                else
                    
                    d.triggGlob(ind)=i;
                    d.triggTime(ind)=i/d.recFreq;
                    d.eventType(ind)=1; % this is new, all ttls become 1s
                    fndFirst=0;
                    d.ttlMarker(ind).end=i/d.recFreq;
                    leeway=d.recFreq*0.015;
                end
            end  
        end
    else
        leeway=leeway-1;
    end
end
% by default, we will count the very last "event" as the end of rec.
d.nEvents=ind+1;
d.triggGlob(ind+1)=d.tickLen;



%///////////////////////////////////////////////////////////////////
%
% plot the time freq spectra for a particular channel over x-many epocs,
% normalized y many epocs
%////////////////////////////////////////////////////////////////////
function []=compTimF11(varargin)


global S
global d
tossAmount=0.01;
scalesToToss=8;
extra=d.recFreq; % number of samples on each side of the epoch that we pad

ind=1;
normEp=str2num(get(S.normList,'str'));
expEp=str2num(get(S.epocList,'str'));
% 1)compute the time-freq spectra per each epoch
% 2)average the exp tfs and norm tfs
% 3)normalize exp tfs to norm tfs by
%       subtracting the mean(avg(normtf)) for individual pseudofrequencies

% 1)
minL=9999999999;
for i=1:length(normEp)
    ind=normEp(i);
    st=d.triggGlob(ind)-extra; % start and end of the epoch
    en=d.triggGlob(ind+1)+extra;
    % do this for every channel in the chanList
    [P,Fa,t,ph]=btfx(d.recData(d.chan,st:en),d.recFreq,extra);
    % now P and Fa contain power and pseudo freqs resp.
    normP(i,1:length(Fa),1:length(P))=P;        
    minL=min(minL,length(P));
end

% now the epochs
[a,b]=size(P); % a is the num of pseudofreq
normP(:,:,minL+1:b)=[];
b=minL; % want the shortest epoch time
% trim the ends
%now go over all the points and get the mean
meanIti(1:a,1:b)=mean(normP(:,1:a,1:b));
stdDevIti(1:a,1:b)=std(normP(:,1:a,1:b));


minLex=9999999999;
for i=1:length(expEp)
    ind=expEp(i);
    st=d.triggGlob(ind)-extra; % start and end of the epoch
    en=d.triggGlob(ind+1)+extra;
    [P,Fa,t,ph]=btfx(d.recData(d.chan,st:en),d.recFreq,extra);
    % now P and Fa contain power and pseudo freqs resp.
    expP(i,1:length(Fa),1:length(P))=P; 
    % now go through all the points and find
    minLex=min(minLex,length(P));
end

[a,b]=size(P); % a is the num of pseudofreq
expP(:,:,minLex+1:b)=[];
b=minLex; % want the shortest epoch time

% standardize the individual spectra
% 1. find the number of times you need to repmat the iti tf
repCnt=minLex/minL+1;
% rep the iti
itiReped=repmat(meanIti,1,repCnt);
itiDevReped=repmat(stdDevIti,1,repCnt);
itiReped(:,:,minLex+1:b)=[];
itiDevReped(:,:,minLex+1:b)=[];

%2.for all the epocs, for every point subtract the iti "mask"
for i=length(expEp)    
    
    ll=squeeze(expP(i,1:a,1:b))./itiReped(1:a,1:b);
    stdExp(i,1:a,1:b)=squeeze(ll(1:a,1:b));
end
meanEp=squeeze(mean(expP(:,1:a,1:b)));

pvals=1.0-normcdf(meanEp(1:a,1:b),itiReped(1:a,1:b),itiDevReped(1:a,1:b));

meanStdEp=squeeze(mean(stdExp(:,1:a,1:b)));

for i=1:a
    for j=1:b
        if(pvals(i,j)>0.05)
           meanStdEp(i,j)=0; 
            
        end
    end
end
      



% here we average the tfs over all the rest epochs


% now mean everything over the diffferent channels

% now plot the mean time freq spec for rest and for experiment
tb=findobj('name','timFre');
if(tb>1)    
    figure(tb);
else
    figure('name','timFre');
end


colormap( jet);
po=pcolor(1:minLex,Fa(scalesToToss:length(Fa)),(meanStdEp(scalesToToss:length(Fa),1:minLex)));
set(po,'edgecolor','none');


%po2=pcolor(1:minLex,Fa(scalesToToss:length(Fa)),(meanPvals(scalesToToss:length(Fa),1:minLex)));
%set(po2,'edgecolor','none');

%figure(55);
%po3=pcolor(1:minLex,Fa(scalesToToss:length(Fa)),(meanPowChange(scalesToToss:length(Fa),1:minLex)));
%set(po3,'edgecolor','none');
%title sig only

%set(gca,'Ylim',[3 300]);
colorbar
%axHdl = get(po,'Parent'); %get the axes parent of the surface
%you will see the CLIm is set to the range of your data
%cLim = get(axHdl,'CLim') %you will see the CLIm is set to the range of your data

%now set the CLIM to the range we want
%set(axHdl,'CLim',[0,10])















































%///////////////////////////////////////////////////////////////////
%
% plot the time freq spectra for a particular channel over x-many epocs,
% normalized y many epocs
%////////////////////////////////////////////////////////////////////

function[st] = getJuiciestWindow(ar,windy,cuttoff)

[b a]=size((ar));
st=1;

for i=1:a-windy-1
    wncn(i)=0;
    for j=1:windy/10:windy %width, move up by 10% of winlen
       for p=1:b %height
           if(ar(p,j+i)>cuttoff)
            wncn(i)=wncn(i)+1;
           end
       end       
    end    
    if(wncn(i)>wncn(st))
        st=i;
    end
end








function []=compTimF_window(varargin)
global S
wly=1000;
for i=1:25
    set(S.normList,'str',num2str(i*2-1));
    set(S.epocList,'str',num2str(i*2));
    lk=[];
    [lk,scl]=compTimF_wrapped();
    [c d]=size(lk);
    wn(i,1:c,1:d)=lk;
    tb=findobj('name','timFre');
    fn=strcat('e:\\matplots\\tf',num2str(i*2),'.png');
    saveas(tb,fn,'png');
    juici(i)=getJuiciestWindow(squeeze(wn(i,:,:)),wly,10); % find the best 1 second window with
                                        % most 5x increases in P
end

% now that we got all the best windows
% average them!
tt=squeeze(wn(1,:,:));
[b a]=size(tt);
avWind=zeros(b,wly);
for j=1:wly %windowpoints
    for k=1:b
        accum=0;
        index=1;
        for i=1:25 %% all epochs
              accum=accum+wn(i,k,juici(i)+j);
             if(wn(i,k,juici(i)+j)~=0)             
                 index=index+1;
             end                
        end
        if(index>1),avWind(k,j)=accum/(index-1); end
     
    end    
end

tb=findobj('name','combWind');
if(tb>1)    
    figure(tb);
else
    figure('name','combWind');
end
po=pcolor(1:wly,scl(1:b),avWind(1:b,1:wly));
set(po,'edgecolor','none');
'average best window starts at', mean(juici)


function [tf_array,scl]=compTimF_wrapped(varargin)


global S
global d
tossAmount=0.01;
scalesToToss=14;
extra=d.recFreq; % number of samples on each side of the epoch that we pad

ind=1;
normEp=str2num(get(S.normList,'str'));
expEp=str2num(get(S.epocList,'str'));
% 1)compute the time-freq spectra per each epoch
% 2)average the exp tfs and norm tfs
% 3)normalize exp tfs to norm tfs by
%       subtracting the mean(avg(normtf)) for individual pseudofrequencies

% 1)
minL=9999999999;
for i=1:length(normEp)
    ind=normEp(i);
    st=d.triggGlob(ind)-extra; % start and end of the epoch
    en=d.triggGlob(ind+1)+extra;
    % do this for every channel in the chanList
    [P,Fa,t,ph]=btfx(d.recData(d.chan,st:en),d.recFreq,extra);
    % now P and Fa contain power and pseudo freqs resp.
    normP(i,1:length(Fa),1:length(P))=P;    
    
    minL=min(minL,length(P));
end
[a,b]=size(P); % a is the num of pseudofreq
normP(:,:,minL+1:b)=[];
b=minL; % want the shortest epoch time
% trim the ends

% now lets glue together all the normalization bits
for i=1:length(normEp)
   for j=1:a
     glued(j,1+(i-1)*minL:i*minL)=normP(i,j,1:minL);       %glued: for Fa(j) and time*(minL..),whats the power
   end
end

% now for every frequency bin, find the mean and stddev
   for j=1:a
      meanNormP(j)=mean(glued(j,:));
      stdNormP(j)=std(glued(j,:));
   end


minLex=9999999999;
for i=1:length(expEp)
    ind=expEp(i);
    st=d.triggGlob(ind)-extra; % start and end of the epoch
    en=d.triggGlob(ind+1)+extra;
    [P,Fa,t,ph]=btfx(d.recData(d.chan,st:en),d.recFreq,extra);
    % now P and Fa contain power and pseudo freqs resp.    
    expP(i,1:length(Fa),1:length(P))=P; 
    % now go through all the points and find
    minLex=min(minLex,length(P));
end



[a,b]=size(P); % a is the num of pseudofreq
expP(:,:,minLex+1:b)=[];
b=minLex; % want the shortest epoch time



for i=1:a
    for j=1:b
        avExpP(i,j)=mean(expP(:,i,j));
    end
end

% go through all the tfs, and all the fas and find the z value
for k=1:b

 for j=1:a
     
    accum=0;
    cnt=0;
    for i=length(expEp)    
        pVal(i,j,k)=1-normcdf(expP(i,j,k),meanNormP(j),stdNormP(j));
        % ok now, if this is a not sig change, we say that, powChange is 0
        if(pVal(i,j,k)>0.05)
            %powChange(i,j,k)=0;
        else
          cnt=cnt+1;
          accum=accum+ (expP(i,j,k)/meanNormP(j));
            
            
           % powChange(i,j,k)=expP(i,j,k)/meanNormP(j);
        end

    end
    if(cnt==0)
       meanPowChange(j,k)=0;
    else
        meanPowChange(j,k)=accum/cnt;
    end
   % meanPowChange(j,k)=mean(powChange(:,j,k)); 
  
 end
end


% now plot the mean time freq spec for rest and for experiment
tb=findobj('name','timFre');
if(tb>1)    
    figure(tb);
else
    figure('name','timFre');
end
% subtract the mean rest Power value from all the pseudofreqs

 %   for i= 1:a
 %     avExpP(i,:)=(avExpP(i,:)-meanNormP(i)); 
 %   end

colormap( jet);
po=pcolor(1:minLex,Fa(scalesToToss:length(Fa)),(meanPowChange(scalesToToss:length(Fa),1:minLex)));
set(po,'edgecolor','none');


%po2=pcolor(1:minLex,Fa(scalesToToss:length(Fa)),(meanPvals(scalesToToss:length(Fa),1:minLex)));
%set(po2,'edgecolor','none');

%figure(55);
%po3=pcolor(1:minLex,Fa(scalesToToss:length(Fa)),(meanPowChange(scalesToToss:length(Fa),1:minLex)));
%set(po3,'edgecolor','none');
%title sig only

%set(gca,'Ylim',[3 300]);
colorbar
axHdl = get(po,'Parent'); %get the axes parent of the surface
cLim = get(axHdl,'CLim') %you will see the CLIm is set to the range of your data
%now set the CLIM to the range we want
set(axHdl,'CLim',[0,30])




tf_array=(meanPowChange(scalesToToss:length(Fa),1:minLex));
scl=Fa(scalesToToss:length(Fa));









function []=compTimF(varargin)


global S
global d
tossAmount=0.01;
scalesToToss=5;
extra=d.recFreq; % number of samples on each side of the epoch that we pad

ind=1;
normEp=str2num(get(S.normList,'str'));
expEp=str2num(get(S.epocList,'str'));
% 1)compute the time-freq spectra per each epoch
% 2)average the exp tfs and norm tfs
% 3)normalize exp tfs to norm tfs by
%       subtracting the mean(avg(normtf)) for individual pseudofrequencies

% 1)
minL=9999999999;
for i=1:length(normEp)
    ind=normEp(i);
    st=d.triggGlob(ind)-extra; % start and end of the epoch
    en=d.triggGlob(ind+1)+extra;
    % do this for every channel in the chanList
    [P,Fa,t,ph]=btfx(d.recData(d.chan,st:en),d.recFreq,extra);
    % now P and Fa contain power and pseudo freqs resp.
    normP(i,1:length(Fa),1:length(P))=P;    
    
    minL=min(minL,length(P));
end
[a,b]=size(P); % a is the num of pseudofreq
normP(:,:,minL+1:b)=[];
b=minL; % want the shortest epoch time
% trim the ends

% now lets glue together all the normalization bits
for i=1:length(normEp)
   for j=1:a
     glued(j,1+(i-1)*minL:i*minL)=normP(i,j,1:minL);       %glued: for Fa(j) and time*(minL..),whats the power
   end
end

% now for every frequency bin, find the mean and stddev
   for j=1:a
      meanNormP(j)=mean(glued(j,:));
      stdNormP(j)=std(glued(j,:));
   end


minLex=9999999999;
for i=1:length(expEp)
    ind=expEp(i);
    st=d.triggGlob(ind)-extra; % start and end of the epoch
    en=d.triggGlob(ind+1)+extra;
    [P,Fa,t,ph]=btfx(d.recData(d.chan,st:en),d.recFreq,extra);
    % now P and Fa contain power and pseudo freqs resp.    
    expP(i,1:length(Fa),1:length(P))=P; 
    % now go through all the points and find
    minLex=min(minLex,length(P));
end



[a,b]=size(P); % a is the num of pseudofreq
expP(:,:,minLex+1:b)=[];
b=minLex; % want the shortest epoch time



for i=1:a
    for j=1:b
        avExpP(i,j)=mean(expP(:,i,j));
    end
end

% go through all the tfs, and all the fas and find the z value
for k=1:b

 for j=1:a
     
    accum=0;
    cnt=0;
    for i=length(expEp)    
        pVal(i,j,k)=1-normcdf(expP(i,j,k),meanNormP(j),stdNormP(j));
        % ok now, if this is a not sig change, we say that, powChange is 0
        
        %if(pVal(i,j,k)>0.05)
            %powChange(i,j,k)=0;
            %else
            if(1)
          cnt=cnt+1;
          accum=accum+ (expP(i,j,k)/meanNormP(j));
            
            
           % powChange(i,j,k)=expP(i,j,k)/meanNormP(j);
        end

    end
    if(cnt==0)
       meanPowChange(j,k)=0;
    else
        meanPowChange(j,k)=accum/cnt;
    end
   % meanPowChange(j,k)=mean(powChange(:,j,k)); 
  
 end
end


% now plot the mean time freq spec for rest and for experiment
tb=findobj('name','timFre');
if(tb>1)    
    figure(tb);
else
    figure('name','timFre');
end
% subtract the mean rest Power value from all the pseudofreqs

 %   for i= 1:a
 %     avExpP(i,:)=(avExpP(i,:)-meanNormP(i)); 
 %   end

colormap( jet);
po=pcolor(1:minLex,Fa(scalesToToss:length(Fa)),(meanPowChange(scalesToToss:length(Fa),1:minLex)));
set(po,'edgecolor','none');

colorbar
axHdl = get(po,'Parent'); %get the axes parent of the surface
cLim = get(axHdl,'CLim') %you will see the CLIm is set to the range of your data

for z=1:minLex
    accum=0;
    cnt=0;
    for i=1:length(Fa)
        if((Fa(i)>70 && Fa(i)<116) ||( Fa(i)>124 && Fa(i)<300)) % if high gamma, average it!
            accum=accum+meanPowChange(i,z);
            cnt=cnt+1;
        end
    end
    meanHG(z)=accum/cnt;
end


% now plot the mean time freq spec for rest and for experiment
tb=findobj('name','meanHighGamma');
if(tb>1)    
    figure(tb);
else
    figure('name','meanHighGamma');
end
plot(meanHG);















function [] =epPropWind(varargin)
global d
global S
set(S.epPropFig,'visible','on');


function [] =imEpWind(varargin)
global d
global S
set(S.importEpochFig,'visible','on');



function [] =artBut(varargin)
global d
global S
set(S.artifactFig,'visible','on');

function [] =arf(varargin)
global d
global S
set(S.artifactFig,'visible','off');

function [] =exf(varargin)
global d
global S
set(S.exportEpochFig,'visible','off');


function [] =larf(varargin)
global d
global S
set(S.listArt,'visible','off');


function [] =eprf(varargin)
global d
global S
set(S.listArt,'visible','off');

  S.epochInfoButton 
  
  


function [] =exEpWind(varargin)
global d
global S
set(S.exportEpochFig,'visible','on');



function [] =setEpOpt(varargin)
global d
global S

offs= str2num( get(S.OffsetInp,'String'));
maxLen = str2num( get(S.maxEpLen,'String'));

if(offs>0)
 d.offs=offs;
end

if(maxLen>0)
  d.maxLen=maxLen;
end
set(S.epPropFig ,'visible','off');

plotEpoch();

function [] =setImpOpt(varargin)
global d
global S

set(S.importEpochFig ,'visible','off');



function [] =findEps(varargin)
global d
global S
global eegToImport


    [t1 t2]=size(eegToImport.event);
     noEvs=0;
    if(t1==0)
        noEvs=1;
        d.imp_nEvents=0;
    else
        d.imp_triggGlob=cell2mat({eegToImport.event(:).latency});
        [dum,d.imp_nEvents]=size(d.imp_triggGlob);
        d.imp_recData=eegToImport.data;
        d.imp_eventType=cell2mat({eegToImport.event(:).type});
        d.imp_triggTime=d.imp_triggGlob/d.recFreq;
        d.imp_nEvents=d.imp_nEvents+1;
        [ffdummy,d.imp_tickLen]=size(eegToImport.data); 
        d.imp_triggTime(d.imp_nEvents)=d.imp_tickLen/d.recFreq;
        
        
        
        d.imp_recFreq=d.recFreq;
    end
    
    if(d.imp_nEvents<=1)
        noEvs=1;
        d.imp_Events=0;
    end
    [d.imp_chanCnt,d.imp_tickLen]=size(eegToImport.data);

    if(eegToImport.data(d.imp_chanCnt,1)==0)
        haveEvInfo=1;
    end
    % lets check if this is binary denoted epochs
    if(noEvs==1)
       d.imp_triggersTTL=0;
       for i=1:d.imp_tickLen
          if(eegToImport.data(d.imp_chanCnt,i)==1)
              d.imp_nEvents=d.imp_nEvents+1;
              d.imp_triggGlob(d.imp_nEvents)=i;
              d.imp_triggTime(d.imp_nEvents)=i/d.recFreq;
          end
       end
       d.imp_nEvents=d.imp_nEvents+1;
        d.imp_triggGlob(d.imp_nEvents)=d.imp_tickLen;
              d.imp_triggTime(d.imp_nEvents)=d.imp_tickLen/d.recFreq;
    end
    % we define the very last event as the end of the recs
    isTTL=0;
    if(d.imp_nEvents>1)
        d.imp_nEvents=d.imp_nEvents+1;
        d.imp_triggGlob(d.imp_nEvents)=d.imp_tickLen;
    else
        % if we didn't find any events by looking for 1s and 0s, lastly,
        % lets check if this is TTL pulse denoted
        isTTL=1;
    end    
    d.imp_triggersTTL=0;
    if(isTTL==1)
        largestDelta=0;
        d.imp_recData=eegToImport.data;
        d.imp_recFreq=d.recFreq;
        for i=1:d.imp_tickLen/4
            if(abs(d.imp_recData(d.imp_chanCnt,i+1)-d.imp_recData(d.imp_chanCnt,i))>largestDelta)
                largestDelta=abs(d.imp_recData(d.imp_chanCnt,i+1)-d.imp_recData(d.imp_chanCnt,i));
            end
        end    
        % now go through all the chans extracting the trigger stamps
        cutOff=largestDelta/10;
        ind=0;
        fndFirst=0;
        fndVeryFirst=0;

        leeway=0; %the signals are not exactly straight, so we need to make sure
                  % we dont pick up two triggers on where it is really just one
        %it seems that the very first spike marks the begining of data not an epoch!
       minEpochLenCutoff=0.160; % we will have a min of 120 ms before starting a new epoch
                         % otherwise we just grow the previous trigger end 


        %it seems that the very first spike marks the begining of data not an epoch!
        for i=1:d.imp_tickLen-1
            if(leeway<=0)
                if(abs(d.imp_recData(d.imp_chanCnt,i+1)-d.imp_recData(d.imp_chanCnt,i))>cutOff)
                    %lets see if this is very first spike
                    if(fndVeryFirst==0)            
                        fndVeryFirst=1;
                        leeway=d.imp_recFreq*0.015;
                        veryFirstTime=i/d.imp_recFreq;
                    else
                        %check if this is the first marker signal
                        if(fndFirst==0)


                            if(ind>1)
                                % if the prev epoch is long enough, start a new one
                              if(i/d.imp_recFreq-d.imp_ttlMarker(ind).end>minEpochLenCutoff)
                                ind=ind+1;
                                % we are only saving the first part of the wave             
                                fndFirst=1;
                                d.imp_ttlMarker(ind).start=i/d.imp_recFreq;
                                leeway=d.imp_recFreq*0.015;
                                % if the new epoch is too short...we just extend
                                % the trigger.
                              else

                                  d.imp_ttlMarker(ind).end=i/d.imp_recFreq;
                                  leeway=d.imp_recFreq*0.015;
                                  d.imp_triggGlob(ind)=i;
                                  d.imp_triggTime(ind)=i/d.imp_recFreq;
                                  d.imp_eventType(ind)=d.imp_eventType(ind)+0.5;
                              end
                            else
                                ind=ind+1;
                                % we are only saving the first part of the wave             
                                fndFirst=1;
                                d.imp_ttlMarker(ind).start=i/d.imp_recFreq;
                                if(d.imp_ttlMarker(ind).start-veryFirstTime < minEpochLenCutoff)

                                    d.imp_ttlMarker(ind).end=d.imp_ttlMarker(ind).start;
                                    d.imp_ttlMarker(ind).start=veryFirstTime;
                                    d.imp_eventType(ind)=1;
                                    d.imp_triggGlob(ind)=i;
                                    d.imp_triggTime(ind)=i/d.imp_recFreq;
                                    fndFirst=0;                            
                                end
                                leeway=d.imp_recFreq*0.015;                         
                            end
                        else

                            d.imp_triggGlob(ind)=i;
                            d.imp_triggTime(ind)=i/d.imp_recFreq;
                            d.imp_eventType(ind)=1; % this is new, all ttls become 1s
                            fndFirst=0;
                            d.imp_ttlMarker(ind).end=i/d.imp_recFreq;
                            leeway=d.imp_recFreq*0.015;
                        end
                    end  
                end
            else
                leeway=leeway-1;
            end
        end
        % by default, we will count the very last "event" as the end of rec.
        d.imp_nEvents=ind+1;
        d.imp_triggGlob(ind+1)=d.imp_tickLen;
        d.imp_triggersTTL=1;        
    end
plotImpoch();
    
    
    
function [] = plotImpoch(varargin)
global d
global S

figure(S.fh);

%d.epoc holds the value of the current trigg

stPl=d.imp_triggGlob(d.epoc);  
enPl=d.imp_triggGlob(d.epoc+1);

if(d.maxLen>0)

    if(enPl-stPl>d.recFreq/1000*d.maxLen)
        enPl=stPl+d.recFreq/1000*d.maxLen;
    end
end
        
    
x=d.timeData(stPl:enPl);
y=d.imp_recData(d.chan:d.chan,stPl:enPl)*d.ampMult;
d.timeData(stPl:enPl);
h=gca;
tmpY=y-mean(y);
cl='b';


plot(x,tmpY,'g');



% if we have ttlMarkers, show the position of the 2nd ttl marker
if(d.imp_triggersTTL==1)
    
    hold on;
         
        st=d.imp_ttlMarker(d.epoc).start*d.recFreq-stPl;
        if(st<1),st=1;end
        en=d.imp_ttlMarker(d.epoc).end*d.recFreq-stPl;    
        lp= plot(x(st:en),tmpY(st:en));
        set(lp,'LineWidth',1.5);
        set(lp,'Color',[1 0.5 0.2]);
    hold off;
end



set(h,'YTick',[])
set(h,'XTick',[])
set(h,'XLim',[d.timeData(stPl:stPl),d.timeData(stPl:stPl)+d.intLen])
set(h,'YLim',[-1,1])
set(h,'Box','off')
set(h,'XColor',get(S.fh,'color'))

function []= mergeEpochs(varargin)
    global d
    global S
    d.triggTime(d.nEvents)=d.tickLen/d.recFreq;
    ep2im=str2num(get(S.epList,'str'));
    for i=ep2im
        d.recData(:,d.tickLen+1:d.tickLen+d.imp_triggGlob(i+1)-d.imp_triggGlob(i)+1)=d.imp_recData(:,d.imp_triggGlob(i):d.imp_triggGlob(i+1));
        if(d.imp_triggersTTL==1)
            d.ttlMarker(d.nEvents).start=(d.tickLen+1)/d.recFreq;
            d.ttlMarker(d.nEvents).end=((d.tickLen+1)/d.recFreq)+d.imp_ttlMarker(i).end-d.imp_ttlMarker(i).start;
        end
        d.tickLen=length(d.recData(1,:));
        d.triggGlob(d.nEvents+1)=d.tickLen;
        d.triggTime(d.nEvents+1)=d.tickLen/d.recFreq;
        if(d.eventType~=-1) 
            d.eventType(d.nEvents+1)= d.imp_eventType(i);
        end
         % init the selections
          for p=1:d.chanCnt, d.sl(p,d.nEvents).ne= 0;d.sl(p,d.nEvents).ev(1:20,1:2)=zeros(20,2); end
         d.valEp(1:d.chanCnt,d.nEvents)=1;
         d.baseEp(1:d.chanCnt,d.nEvents)= 0;
         d.expEp(1:d.chanCnt,d.nEvents)=0;
         d.nEvents=d.nEvents+1;
    end
    
    d.timeData=0:1.0/d.recFreq:1.0/d.recFreq*d.tickLen;
    
% save the select epochs    


function []= saveEpochs(varargin)
    global d
    global S
    d.triggTime(d.nEvents)=d.tickLen/d.recFreq;
    expVar=get(S.expEpVarName,'str');
    MAX_LEN_DATA_EXP=10000; % current limitation is 10seconds of 1000 Hz data
    
    
    numToExp=str2num(get(S.epExpNumList,'str'));
    typeToExp=str2num(get(S.epExpTypeList,'str'));
    minLen=str2num(get(S.epExpMinLen,'str'));
    amtPad=str2num(get(S.epPadlen,'str'));
    amtPadEnd=str2num(get(S.epPadlenEnd,'str'));
    doIgnore=get(S.ignoreTags,'Value');
    
    
   
    
    
    
    % for the particular channel, we need to build a stack of epochs that 
    % meet the desired criteria....so how to do:
    % 1) first, see if we are selecting on the basis of epoch number or
    % epoch type    
    if(minLen>0)
        MAX_LEN_DATA_EXP=minLen/1000*d.recFreq;
    end
    pancakeNum=1;
    ind=1;
    if(length(numToExp)<length(typeToExp)) % if exporting by type
       for l=1:d.nEvents-1
           if(find(typeToExp==d.eventType(l),1))
                numToExp(ind)=l;
                ind=ind+1;
           end
       end
    end
    
    
    dataToExport.data=zeros(length(numToExp),MAX_LEN_DATA_EXP);
    for j=1:length(numToExp)
        % need to see if this epoch makes the cut
        % first on the basis of length
        if((d.triggGlob(numToExp(j)+1)-d.triggGlob(numToExp(j)))/d.recFreq*1000 > minLen)
           % now if this epoch meets the length requirement, need to
           % see if it is flagged for artifacts
           canInclude=1;
           if(d.sl(numToExp(j)).ne>0 && ~doIgnore && d.valEp(d.chan,numToExp(j)))                      
              for z=1:d.sl(d.chan,numToExp(j)).ne 
                stOff=(d.sl(d.chan,numToExp(j)).ev(z,1)*d.recFreq-d.triggGlob(numToExp(j)))/d.recFreq*1000;
                if(stOff<minLen) % if the distance to the start of the mark is less than whatever, we cant include it
                    canInclude=0;
                end
              end                      
           end                   
           % now if the epoch passed all the criteria for inclusion
           % pancake it onto the stack of epochs
           if( canInclude)
               chunkToExport=[];
               endP=d.triggGlob(numToExp(j)+1)+(amtPadEnd/1000*d.recFreq); 
               if(minLen>0) % if we have a certain minLength in mind, we will be trimming to it
                   if((d.triggGlob(numToExp(j)+1) - d.triggGlob(numToExp(j)+1))/d.recFreq*1000 > minLen)
                       endP=d.triggGlob(numToExp(j)+1)+(minLen/1000*d.recFreq);
                   end
               end
               chunkToExport=d.recData(d.chan,d.triggGlob(numToExp(j))-(amtPad/1000*d.recFreq): endP);  
               dataToExport.data(pancakeNum,1:length(chunkToExport))=chunkToExport;
               dataToExport.epochInfo(pancakeNum).originalEpoch=numToExp(j);
               if(d.eventType~=-1)
                   dataToExport.epochInfo(pancakeNum).epochType=d.eventType(numToExp(j));
               end
               dataToExport.epochInfo(pancakeNum).prePad=(amtPad/1000*d.recFreq);
               dataToExport.epochInfo(pancakeNum).endPad=(amtPadEnd/1000*d.recFreq);
               dataToExport.epochInfo(pancakeNum).epochLength=d.triggGlob(numToExp(j)+1) - (d.triggGlob(numToExp(j))-(amtPad/1000*d.recFreq))+(amtPadEnd/1000*d.recFreq)+1;                       
               pancakeNum=pancakeNum+1;
           end
        end                
    end            
 
        
        
    

     assignin('base',expVar,dataToExport);
     
% rejects epochs if in this epoch the variances are unequal.     
function []= findArtifacts(varargin)
    global S
    global d
    doRej=(get(S.autorejchk,'Value'));
    rejAlph= str2num(get(S.rejAlpha,'str'));
    'Searching for artifacts'
    % we will go through all the chans, computing overall variance
    % next we will go through all the epochs, computing variance
    for i=1:d.chanCnt
        allD=d.recData(i,:);
        for j=1:d.nEvents-1
            epD=[];
            epD=d.recData(i,d.triggGlob(j):d.triggGlob(j+1));
            
            [v,p]=vartest2(epD,allD,rejAlph,'right');
            d.artSearch(i,j,1)=v;            
            d.artSearch(i,j,2)=p;
            if(v==1&&doRej)
               d.valEp(i,j)=0; 
            end
        end        
    end
    assignin('base', 'ArtifactRejectionData',d.artSearch);
    'Finished artifact search'
    
function [] =larv(varargin) % list all rejected
global d
global S
set(S.listArt,'visible','on');

set(S.artListLabel,'str','');
listStr=sprintf('%s\n\n%5s    %5s    %7s\n','Artifacts:','Chan','Epoch','Cause');
for i=1:d.chanCnt
   for j=1:d.nEvents-1
      if(d.artSearch~=-1)
       if(d.artSearch(i,j,1)==1)
            listStr=sprintf('%s%5d    %5d    %7s    %.4f\n',listStr,i,j,'AUTO-R.',d.artSearch(i,j,2));
       end
      end
      if (d.sl(i,j).ne>0 || d.valEp(i,j)==0)
             listStr=sprintf('%s%5d    %5d    %10s\n',listStr,i,j,'USER');            
      end
       
   end    
end

set(S.artListLabel,'str',listStr);


    
function [] =epin(varargin) % list all rejected
global d
global S


  set(S.epochListFig,'visible','on');
  exist('d.eventType')
haveType=1;
 if(d.eventType==-1 )
   haveType=0; 
end
    
set(S.epListLabel,'str','');
if(haveType)
    listStr=sprintf('Epoch #    Start   End   Length(samples)   Length(time)     Event Type\n');
else
    listStr=sprintf('Epoch #    Start   End   Length(samples)   Length(time)     \n');
end
if(haveType)
    for j=1:d.nEvents-1
      listStr=sprintf('%s%8d    %5d    %5d       %5d             %.3fs                      %d\n',listStr,j,d.triggGlob(j),d.triggGlob(j+1),d.triggGlob(j+1)-d.triggGlob(j),(d.triggGlob(j+1)-d.triggGlob(j))/d.recFreq,d.eventType(j));
    end    
else
    for j=1:d.nEvents-1
      listStr=sprintf('%s%8d    %5d    %5d       %5d             %.3fs\n',listStr,j,d.triggGlob(j),d.triggGlob(j+1),d.triggGlob(j+1)-d.triggGlob(j),(d.triggGlob(j+1)-d.triggGlob(j))/d.recFreq);
    end   
end

set(S.epListLabel,'str',listStr);










function [] = plotAllEpochs(varargin)
global d
global S

figure(S.allChans);

%d.epoc holds the value of the current trigg

stPl=d.triggGlob(d.epoc);  
enPl=d.triggGlob(d.epoc+1);

if(d.maxLen>0)
    if(enPl-stPl>d.recFreq/1000*d.maxLen)
        enPl=stPl+d.recFreq/1000*d.maxLen;
    end
end
        
    
if(d.offs>0)
    if(stPl>(d.offs*d.recFreq/1000))
      stPl=stPl-(d.offs*d.recFreq/1000);
    end
end


x=d.timeData(stPl:enPl);


totHeight=100;
bumpUp=totHeight/d.chanCnt;
holding=0;
hold off;
cla(S.plAll);

for z=1:d.chanCnt
    y=d.recData(z,stPl:enPl)*d.ampMult;
    % demean
    tmpY=y-mean(y)+bumpUp*z;
    
       h=gca;


    cl='b';

    if(d.baseEp(z,d.epoc)==1)    
        cl='g';
    end

    if(d.expEp(z,d.epoc)==1)
        cl='m';
    end


    if(d.valEp(z,d.epoc)==0)
        cl='k';
    end
    if(holding==0)
        hold on;
        holding=1;
    end    
    plot(x,tmpY,cl);
    
    
    if(d.sl(z,d.epoc).ne>0)

        
        for b=1: d.sl(z,d.epoc).ne
            st=(d.sl(z,d.epoc).ev(b,1))*d.recFreq-stPl;
            en=(d.sl(z,d.epoc).ev(b,2))*d.recFreq-stPl;
            if(en+stPl>enPl) en=enPl-stPl;end
            if(st<1),st=1;end
            lp= plot(x(st:en),tmpY(st:en),'r');
            set(lp,'LineWidth',1.5);
        end  

        
    end
    

    
end
hold off;






set(h,'YTick',1:bumpUp:bumpUp*d.chanCnt);
set(h,'YTickLabel',1:d.chanCnt)
set(h,'XTick',[])
set(h,'XLim',[d.timeData(stPl:stPl),d.timeData(stPl:stPl)+d.intLen])
set(h,'YLim',[-1*bumpUp,totHeight+bumpUp])

set(h,'Box','off')
set(h,'XColor',get(S.fh,'color'))
set(gca,'ButtonDownFcn',{@dragSelectionRect});

%set the checkboxes
set(S.buttval,'Value',d.valEp(d.chan,d.epoc));
figure(S.fh);
