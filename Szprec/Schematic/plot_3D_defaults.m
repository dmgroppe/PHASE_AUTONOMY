function cfg = plot_3D_defaults()

cfg=[];
cfg.view = 'l';
cfg.figid=1;
cfg.elecshape='sphere';
%cfg.elecshape='marker';
%cfg.eleccolors=rand(length(elecnames),1)*2-1;

cfg.colorscale='minmax';
cfg.plotcbar='n';
cfg.showlabels='n';
cfg.units='r';
cfg.opaqueness = 0.5;
cfg.elecnames = [];
%cfg.overlay_parcellation='DK';
cfg.rotate3d = 'n';