function edgeImage = edge_detect(im, threshold)
%#codegen
%assert(all(size(originalImage) <= [1024 1024]));
%assert(isa(originalImage, 'double'));
%assert(isa(threshold, 'double'));

gray = (0.2989 * double(im(:,:,1)) + 0.5870 * double(im(:,:,2)) + 0.1140 * double(im(:,:,3)))/255;

k = [1 2 1; 0 0 0; -1 -2 -1];
H = conv2(double(gray),k, 'same');
V = conv2(double(gray),k','same');
E = sqrt(H.*H + V.*V);
edgeImage = uint8((E > threshold) * 255);

im3 = repmat(edgeImage, [1 1 3]);
image(im3);