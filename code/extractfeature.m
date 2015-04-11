function ftr = extractfeature(im, nbins)
% ÌáÈ¡Í¼ÏñÌØÕ÷
% xiahouzuoxin

if ndims(im) == 3
    im = rgb2gray(im);
end
im = im2double(im);

imblur  = filter2(fspecial('gaussian',10,10),im);
[fx fy] = gradient(imblur);
imtheta= rem(atan2(fy, fx)+2*pi, 2*pi);
immag = sqrt(fy.^2+fx.^2);
% n = hist(imtheta(:), 16);
% ftr = n(:) /sum(n);
for i = 1:nbins
    left = (i-1)/nbins*2*pi;
    right = i/nbins*2*pi;
    idx = find(imtheta >= left & imtheta < right);
    n(i) = sum(immag(idx));
end
ftr = n(:) /norm(n);


return;