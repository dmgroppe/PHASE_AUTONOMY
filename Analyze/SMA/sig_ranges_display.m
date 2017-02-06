function [] = sig_ranges_display(sig, ap)

sig_ranges = sig_to_ranges(sig, ap.freqs, ap.minr);

if ~isempty(sig_ranges)
    fprintf('\nSignificant ranges:');
    for i=1:size(sig_ranges,2)
        fprintf('\n Range %d: %4.1f - %4.1f', i, ap.freqs(sig_ranges(1,i)),...
            ap.freqs(sig_ranges(2,i)));
    end
else
    fprintf('\nNo ranges of min length %4.1f', ap.minr);
end
