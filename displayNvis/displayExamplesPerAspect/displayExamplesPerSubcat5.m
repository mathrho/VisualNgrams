function displayExamplesPerSubcat5(objname, outdir, VOCyear, traindatatype)
% displayExamplesPerSubcat4 + saving a 1x3 preview & all sample montage

try    
disp(['displayExamplesPerSubcat5(''' objname ''',''' outdir ''',''' VOCyear ''',''' traindatatype ''')' ]);

try evalc('matlabpool');
catch, disp('matlabpool was already open!'); end

dispdir = [outdir '/display/']; mymkdir(dispdir);
numToDisplay = 49;

disp('loading groundtruth info');
load([outdir '/' objname '_' traindatatype '_' VOCyear '.mat'], 'pos');
if exist('/home/ubuntu/JPEGImages/','dir')
    for i=1:numel(pos)
        [~, thisid] = myStrtokEnd(pos(i).im,'/');
        pos(i).im = ['/home/ubuntu/JPEGImages/' thisid];
    end    
end
load([outdir '/' objname '_conf.mat'], 'conf');
load([outdir '/' objname '_mix.mat'], 'model'); 
numComps = numel(model.rules{model.start});
clear model;

% INIT
disp('getting subcategory membership kmeans initialization');
try 
    load([outdir '/' objname '_displayInfo.mat'], 'inds_init'); 
catch    
    %posscores_init = zeros(length(pos), 1);
    %lbbox_init = zeros(length(pos), 4);
    %for i=1:length(pos)
    %    lbbox_init(i,:) = [pos(i).x1 pos(i).y1 pos(i).x2 pos(i).y2];
    %end
end

if ~exist([outdir '/' objname '_lrsplit2.mat'], 'file')
% LRSPLIT1
modeltype = 'lrsplit1';
disp(['loading modeltype ' modeltype]);    
fname = [outdir '/' objname '_' modeltype '.mat'];
try 
    load(fname, 'models', 'model', 'inds_lrsplit1', 'posscores_lrsplit1', 'lbbox_lrsplit1');
    inds_lrsplit1;
    if ~exist('model', 'var'), model = model_merge(models); end
    model_lr = model;
catch
    load(fname, 'models', 'model');
    if ~exist('model', 'var'), model = model_merge(models); end
    disp(' getting subcategory membership info');    
    [inds_lrsplit1, posscores_lrsplit1, lbbox_lrsplit1] = poslatent_getinds(model, pos, conf.training.fg_overlap, 0);
    save(fname, 'inds_lrsplit1', 'posscores_lrsplit1', 'lbbox_lrsplit1', '-append');
end
inds_lrs =  inds_lrsplit1; posscores_lrs = posscores_lrsplit1; lbbox_lrs = lbbox_lrsplit1;
else
% LRSPLIT2
modeltype = 'lrsplit2';
fname = [outdir '/' objname '_' modeltype '.mat'];
disp(['loading modeltype ' modeltype]);
try 
    load(fname, 'inds_lrs2', 'posscores_lrs2', 'lbbox_lrs2');
    inds_lrs2;
catch
    load(fname, 'model', 'models');
    if ~exist('model', 'var'), model = model_merge(models); end
    disp(' getting subcategory membership info');
    [inds_lrs2, posscores_lrs2, lbbox_lrs2] = poslatent_getinds(model, pos, conf.training.fg_overlap, 0);
    save(fname, 'inds_lrs2', 'posscores_lrs2', 'lbbox_lrs2', '-append');
end
inds_lrs =  inds_lrs2; posscores_lrs = posscores_lrs2; lbbox_lrs = lbbox_lrs2;
end

% MIX
modeltype = 'mix';
fname = [outdir '/' objname '_' modeltype '.mat'];
disp(['loading modeltype ' modeltype]);
try 
    load(fname, 'model', 'inds_mix', 'posscores_mix', 'lbbox_mix');
    inds_mix;
    model_mix = model;
catch
    load(fname, 'model');
    disp(' getting subcategory membership info');
    [inds_mix, posscores_mix, lbbox_mix] = poslatent_getinds(model, pos, conf.training.fg_overlap, 0);
    save(fname, 'inds_mix', 'posscores_mix', 'lbbox_mix', '-append');
end

% PARTS
modeltype = 'parts';
fname = [outdir '/' objname '_' modeltype '.mat'];
disp(['loading modeltype ' modeltype]);
if exist(fname,'file')
    try
        load(fname, 'inds_parts', 'posscores_parts', 'lbbox_parts');
        inds_parts;
    catch
        load(fname, 'model');
        disp(' getting subcategory membership info');
        [inds_parts, posscores_parts, lbbox_parts] = poslatent_getinds(model, pos, conf.training.fg_overlap, 0);
        save(fname, 'inds_parts', 'posscores_parts', 'lbbox_parts', '-append');
    end
else
    [inds_parts, posscores_parts, lbbox_parts] = deal([]);
end

disp('getting the montages');
[mimg_init, mlab_init] = getMontagesForModel_latent_wsup(inds_init(:), inds_init(:), ...
    inds_init(:), [], [], [], pos, [], numComps);
%[mimg_lrs1, mlab_lrs1] = getMontagesForModel_latent_wsup(inds_lrs1, inds_lrs1, ...
%    inds_lrs1, posscores_lrs1, [], lbbox_lrs1, pos, [], numComps);
%[mimg_lrs2, mlab_lrs2] = getMontagesForModel_latent_wsup(inds_lrs2, inds_lrs2, ...
%    inds_lrs2, posscores_lrs2, posscores_lrs2, lbbox_lrs2, pos, [], numComps);
[mimg_lrs, mlab_lrs] = getMontagesForModel_latent_wsup(inds_lrs, inds_lrs, ...
    inds_lrs, posscores_lrs, posscores_lrs, lbbox_lrs, pos, [], numComps);
[mimg_mix, mlab_mix] = getMontagesForModel_latent_wsup(inds_mix, inds_mix, ...
    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, [], numComps);
[mimg_parts, mlab_parts] = getMontagesForModel_latent_wsup(inds_parts, inds_parts, ...
    inds_parts, posscores_parts, posscores_parts, lbbox_parts, pos, [], numComps);
% added 30Apr14 -- but not using it as 1000 seems to be too much, 49 should
% be good enuf, so just using the above call instead of doing one more call
% to the function unnecessarily
%[~, ~, mimg_mix_nolab] = getMontagesForModel_latent_wsup(inds_mix, inds_mix, ...
%    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, 1000, numComps);    % 1000 is just some high number to force it to show all examples

disp('Writing montages');
mimg_cell = {mimg_init; mimg_lrs; mimg_mix; mimg_parts};
mlab_cell = {mlab_init; mlab_lrs; mlab_mix; mlab_parts};
writeFinalMontages_latent(dispdir, mimg_cell, mlab_cell);
% [outdir '/display/montageOverIt_' num2str(numComps, '%02d') '.jpg'];

disp('get the 3x3 & AVG image');
%[mimg_lrs3x3, ~, mimg_avg] = get3x3MontagesForModel_latent_wsup(inds_lrs, inds_lrs, ...
%    inds_lrs, posscores_lrs, posscores_lrs, lbbox_lrs, pos, [], numComps, model_lr);
[mimg_lrs3x3, ~, mimg_avg] = get3x3MontagesForModel_latent_wsup(inds_mix, inds_mix, ...
    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, 9, numComps, model_mix);
mimg_lrs7x7 = get3x3MontagesForModel_latent_wsup(inds_mix, inds_mix, ...
    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, 49, numComps, model_mix);
mimg_googprev = getGoogPrevMontagesForModel_latent_wsup(inds_mix, inds_mix, ...
    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, [], numComps, model_mix);
for k=1:numComps+1
    imwrite(mimg_lrs3x3{k}, [dispdir '/montage3x3_' num2str(k-1, '%02d') '.jpg']);
    imwrite(mimg_avg{k}, [dispdir '/montageAVG_' num2str(k-1, '%02d') '.jpg']);
    imwrite(mimg_lrs7x7{k}, [dispdir '/montage7x7_' num2str(k-1, '%02d') '.jpg']);
    imwrite(mimg_googprev{k}, [dispdir '/montageGoogPrev2_' num2str(k-1, '%02d') '.jpg']);
end
myprintfn;

catch
    disp(lasterr); keyboard;
end
