function [A, B, err] = getProbabilisticOutputParams_regularized(conf, labels)
% [A, B, err] = getProbabilisticOutputParams(conf, labels)
%
% Converts a score (such as SVM output or log-likelihood ratio) to a
% probability.
%
% Input:
%   conf(ndata): the confidence of a datapoint (higher indicates greater
%   likelihood of label(i)=1
%   label(ndata): the true label (0 or -1 or neg, 1 for pos) of the datapoint
% Output:
%   A, B: p = 1 / (1+exp(A*conf+B))
%   err: final value that has been minimized

ind = labels==-1;
labels(ind) = 0;

AB = fminsearch(@(AB) logisticError(AB, conf, labels), [-1 0], []);%, optimset('MaxFunEvals', 1000000, 'MaxIter', 1000000));

A = AB(1);
B = AB(2);

err = logisticError([A B], conf, labels)/numel(labels);


function err = logisticError(AB, conf, labels)

labels = double(labels);
p = 1./ (1+exp(AB(1)*conf+AB(2)));

% do this to get a regularised solution (see platts paper for making this
% update!!)
labels(labels==1) = (sum(labels==1)+1)/(sum(labels==1)+2);
labels(labels==0) = 1 / (sum(labels==0)+2);
%err = -sum(labels.*log(p)+(1-labels).*log(1-p));
%disp('adding norm for regularized solution');
err = -sum(labels.*log(p)+(1-labels).*log(1-p))-norm(AB);



