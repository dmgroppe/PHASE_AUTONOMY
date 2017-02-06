function [] = show_region_summary(R)

fprintf('\nWithin ROI = %d\n',R.within_num);
fprintf('Outside of ROI = %d\n',R.out_num);
fprintf('Between  = %d\n',R.between_num);
fprintf('Total = %d\n',R.total_num);
fprintf('Spanned = %d\n',R.span_num);
fprintf('Spanners = %d\n',R.spanners_n);





