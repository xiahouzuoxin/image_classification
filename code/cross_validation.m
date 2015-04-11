function [score str] = cross_validation(label, data, cmd, v, tools)
% 使用自定义的评估函数进行交叉验证，只适用于两类分类问题
% tools :: 'svmtrain' 'train'分别表示LibSVM和LinearSVM
% cmd :: 训练所需参数，不包括-v
% v :: -v 参数

if nargin < 5
    error('must set 5 parameters for cross_validation.\n');
end

len = length(label);
rd = randperm(len);
rd = rd';

predict_labels = [];
true_labels = [];
for i = 1:v
    test_ind = rd(floor((i-1)*len/v)+1 : floor(i*len/v));
    train_ind = [1:len]';
    train_ind(test_ind) = [];
    
    switch lower(tools)
        case 'svmtrain'
            model = svmtrain(label(train_ind), data(train_ind,:),cmd);
            tmp_label = svmpredict(label(test_ind), data(test_ind,:), model);
            
        case 'train'
            model = train(label(train_ind), data(train_ind,:),cmd);
            tmp_label = predict(label(test_ind), data(test_ind,:), model);
            
        otherwise
            error('Unknow tools for cross_validation.\n');
    end
    
    predict_labels = cat(1, predict_labels, tmp_label);
    true_labels = cat(1, true_labels, label(test_ind));    
end

% call @eval_func
[score, str] = eval_func(true_labels,predict_labels,1);  % Recall
fprintf([str '\n']);

end