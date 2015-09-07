function mimg = getGoogPrevMontagesForModel_latent_wsup(inds, inds_past, inds_fut, posscores,...
    possccalib, lbbox, pos, numToDisplay, numComps, model)
% from getMontagesForModel_latent_wsup

try
    
numToDisplay = 4;

mimg  = deal(cell(numComps+1,1));    % +1 to accomodate 0 index
for jj=1:numel(mimg)                        % initialize to dummy
    mimg{jj} = ones(10,10,3);    
end

numpos = numel(pos);

unids = unique(inds(:)); %31May12
unids(unids == 0) = [];
for jj = 1:length(unids)
    myprintf(unids(jj));
    
    A = find(inds == unids(jj));
    if numel(A) < numToDisplay
        disp('too few images'); %keyboard;
        continue;
    end
    
    thisNum = numel(A);        
    allimgs = cell(numToDisplay,1);
    
    if ~isempty(possccalib) %~isempty(posscores)
        %thisscores_tmp = posscores(A,1);
        thisscores_tmp = possccalib(A);
        [sval sinds] = sort(thisscores_tmp, 'descend');
        selInds = sinds(1:thisNum);
    else
        randInds = randperm(numel(A));
        selInds = randInds(1:thisNum);
        %sval = zeros(thisNum, 1);
    end
    
    posindex_col = floor(A(selInds)/(numpos+1));
    %posindex_off = posindex_col+mod(A(selInds),numpos+1);
    % updated 24Mar12
    posindex_off = mod(A(selInds),numpos);
    posindex_off(posindex_off==0) = numpos;
    spos = pos(posindex_off);
    
    siz = model.filters(unids(jj)).size.*40;
    
    %thisbbox = lbbox(posindex_off,repmat((posindex_col*4),1,4)+repmat(1:4, size(posindex_col,1), 1));
    thisbbox = zeros(size(posindex_col,1),4);
    for j=1:size(posindex_col,1)
        thisbbox(j,:) = round(lbbox(posindex_off(j), posindex_col(j)*4 + [1:4]));
    end
    
    spos_orig = spos;
    thisbbox_orig = thisbbox;
    uniqind = getUniqueImgs(spos_orig, 4);    
    spos = spos_orig(uniqind);
    thisbbox = thisbbox_orig(uniqind,:);    
    if length(spos) < 4 % if not many unique, then just use original -- not much you can do in this case!
        spos = spos_orig;
        thisbbox = thisbbox_orig;
    end
            
    %allimgs{j} = draw_box_image(im, thisbbox(j,:));    
    %im = color(imreadx(spos(1)));        
    
    %{    
    %allimgs1 = imresize(imresize(im, [round(size(im,1)/dsz)*dsz NaN]), [dsz NaN]);
    %allimgs2 = imresize(im, [dsz NaN]);             
    allimgs{1} = imresize(color(imreadx(spos(1))), [dsz NaN]);   % 96 bcoz google previous are so, not doing the box as very cluttered at this small resolution
    allimgs{2} = imresize(color(imreadx(spos(2))), [dsz NaN]);
    allimgs{3} = imresize(color(imreadx(spos(3))), [(dsz/2)-1 NaN]);   % 96/2 - 1; -1 as I want to include a 2 pixel margin
    allimgs{4} = imresize(color(imreadx(spos(4))), [(dsz/2)-1 NaN]);
    %}
    
    
    %{
    %allimgs{1} = subarray(color(imreadx(spos(1))), thisbbox(1,3), thisbbox(1,4), thisbbox(1,1), thisbbox(1,2), 1);
    %allimgs{2} = subarray(color(imreadx(spos(2))), thisbbox(2,3), thisbbox(2,4), thisbbox(2,1), thisbbox(2,2), 1);
    %allimgs{3} = subarray(color(imreadx(spos(3))), thisbbox(3,3), thisbbox(3,4), thisbbox(3,1), thisbbox(3,2), 1);
    %allimgs{4} = subarray(color(imreadx(spos(4))), thisbbox(4,3), thisbbox(4,4), thisbbox(4,1), thisbbox(4,2), 1);
    for j=1:4
        allimgs{j} = subarray(color(imreadx(spos(j))), thisbbox(j,2), thisbbox(j,4), thisbbox(j,1), thisbbox(j,3), 1);  
    end
    dsz = size(allimgs{1},1);
    
    tmpmimg = [allimgs{3}; ...
        256*ones([2 size(allimgs{3}, 2) 3]); ...
        imresize(allimgs{4}, [size(allimgs{3},1) size(allimgs{3},2)])];
    
    mimg{unids(jj)+1} = [allimgs{1} ...
        256*ones([dsz 3 3]) ...        
        imresize(allimgs{2}, [size(allimgs{1},1) size(allimgs{1},2)]) ...
        256*ones([dsz 3 3]) ...
        imresize(tmpmimg, [size(allimgs{1},1) NaN])];
        %allimgs{2} ...  
        %tmpmimg
    %}
    
    for j=1:4
        allimgs{j} = subarray(color(imreadx(spos(j))), thisbbox(j,2), thisbbox(j,4), thisbbox(j,1), thisbbox(j,3), 1);  
    end
    dsz = size(allimgs{1},1);
    dsz2 = size(allimgs{1},2);
    mimg{unids(jj)+1} = [allimgs{1} ...
        256*ones([dsz 3 3]) ...
        imresize(allimgs{2}, [size(allimgs{1},1) size(allimgs{1},2)]); ...
        256*ones([3 2*dsz2+3 3]);...
        imresize(allimgs{3}, [size(allimgs{1},1) size(allimgs{1},2)]) ...
        256*ones([dsz 3 3]) ...        
        imresize(allimgs{4}, [size(allimgs{1},1) size(allimgs{1},2)])...
        ];    
end
myprintfn;

catch
    disp(lasterr); keyboard;
end



