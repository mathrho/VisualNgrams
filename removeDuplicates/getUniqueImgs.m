function uniqind = getUniqueImgs(spos, numuniq)

thresh = 10;

numimg = numel(spos);
if numimg < numuniq, disp('In getUniqueImgs: too few images than you want'); keyboard; end

im = cell(numimg, 1);
for i=1:numimg
    im{i} = color(imreadx(spos(i)));
end

k = 0;
uniqind = []; %zeros(numuniq,1);
for i=1:numimg
    thisim = im{i}(:);
    imf = im{i}(:,end:-1:1,:);
    thisimf = imf(:);
    
    flag = 1;
    for j=1:i-1        
        if size(im{i}) == size(im{j}) & ...
                (sum(im{j}(:)-thisim) < thresh | sum(im{j}(:)-thisimf) < thresh)  % img j is similar to img i
            flag = 0;
            break;
        end
    end
    
    if flag ==1
        % j is diff from i
        k = k + 1;
        uniqind = [uniqind; i];
        if k == numuniq
            break;
        end
    end
end
  
%uspos = spos(uniqind);
