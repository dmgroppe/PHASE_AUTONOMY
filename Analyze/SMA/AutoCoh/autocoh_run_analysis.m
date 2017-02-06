function [R] = autocoh_run_analysis(Z, phi, freqs,ap, srate)
[ranges all_ranges] = find_bursts(Z,ap.autocoh.bsize, ap.autocoh.useall);
[amps, avgamps, avglengths, counts, lengths] = get_burst_stats(Z, ranges);
[bursts, ac_count] = autocoh(Z,phi,freqs,ranges,ap, srate);
[prob_dist, hlengths] = jphist(bursts, lengths, avglengths, ap, srate);

R.lengths = lengths;
R.ranges = ranges;
R.all_ranges = all_ranges;
R.bursts = bursts;
R.prob_dist = prob_dist;
R.amps = amps;
R.avgamps = avgamps;
R.counts = counts;
R.ac_count = ac_count;
R.hlengths = hlengths;
R.avglengths = avglengths;