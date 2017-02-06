% USAGE: [] = plot_cfmodulation(mp, ms, params, frq)
%
%       Plots cross frequency modulation results
%
%   Input:
%       mp:     Modulation phase
%       ms:     Modulation strength
%   Params:     analysis params
%   freq:       frequencies


function [] = plot_cfmodulation(mp, ms, params, frq, caxis_range)

if (nargin < 5); caxis_range = []; end;

lfstart = GetIndex(frq, params.display.cfm.fstart);
lfend = GetIndex(frq, params.display.cfm.fend);

if (~isempty(mp))
    ax(1) = subplot(3,1,1);
else
    ax(1) = subplot(1,1,1);
end

if (max(max(ms)) == min(min(ms)))
    fprintf('No range to Modulation Phase to plot.')
    return;
end

%set(gcf, 'Renderer', 'zbuffers');

surf(frq(lfstart:lfend), frq(lfend:end), ms(lfend:end, lfstart:lfend));
axis([frq(lfstart), frq(lfend), frq(lfend), frq(end) min(min(ms(lfend:end, lfstart:lfend))) max(max(ms(lfend:end, lfstart:lfend)))]);
%axis([frq(lfstart), frq(lfend), frq(lfend), frq(end) 0 0.2]);    

view(0,90);
shading interp;
title('Modulation strength');
colorbar
xlabel('Modulating frequency (Hz)');
ylabel('Modulated frequency (Hz)');
if (~isempty(caxis_range))
    caxis(caxis_range);
end

if (~isempty(mp))  
    mp_mag = abs(mp);
    
    if (max(max(mp_mag)) == min(min(mp_mag)))
        fprintf('No range to Modulation Strength to plot.')
        return;
    end
        
    ax(2) = subplot(3,1,2);
    surf(frq(lfstart:lfend), frq(lfend:end), mp_mag(lfend:end, lfstart:lfend));
    axis([frq(lfstart), frq(lfend), frq(lfend), frq(end) min(min(mp_mag(lfend:end, lfstart:lfend))) max(max(mp_mag(lfend:end, lfstart:lfend)))]);
    view(0,90);
    shading interp;
    title('MP - magnitude');
    colorbar
    xlabel('Modulating frequency(Hz)');
    ylabel('Modulated frequency(Hz)');

    mp_a = angle(mp);
    ax(3) = subplot(3,1,3);
    surf(frq(lfstart:lfend), frq(lfend:end), mp_a(lfend:end, lfstart:lfend));
    axis([frq(lfstart), frq(lfend), frq(lfend), frq(end) min(min(mp_a(lfend:end, lfstart:lfend))) max(max(mp_a(lfend:end, lfstart:lfend)))]);
    view(0,90);
    shading interp;
    title('MP - phase angle');
    colorbar
    xlabel('Modulating frequency(Hz)');
    ylabel('Modulated frequency(Hz)');
    
    linkaxes(ax, 'xy');
end