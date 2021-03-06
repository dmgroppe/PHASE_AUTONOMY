% Usage: [] = plot_spectrum(ws, frq, sr, params)

function [] = plot_spectrum(ws, frq, sr, params)

x = get_x(length(ws), sr) - params.ana.baseline;

if (params.disp.norm_to_baseline)
    blsamples = time_to_samples(params.ana.baseline, sr);
    bl = mean(ws(:, 1:blsamples),2);
    for i=1:length(ws);
        ws(:,i) = ws(:,i)./bl;
    end
end


surf(x, frq, ws);
axis([x(1) x(end) frq(1) frq(end) min(min(ws)) max(max(ws))]);
view(0,90);
shading interp;
colorbar
xlabel('Time (ms)')
ylabel('Frequnecy (Hz)');
