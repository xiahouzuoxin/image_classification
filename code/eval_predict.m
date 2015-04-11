function [predict_labels acc dec] = eval_predict(label, data, model, tools)
% ʹ���Զ�����������ʱ��Ԥ��ģ��
% tools: 'libsvm' 'linearsvm'
% ���ߣ��ĺ�����
% ���ڣ�2013.04

switch lower(tools)
    case 'libsvm'
        [predict_labels, ~, dec] = svmpredict(label, data, model);

    case 'linearsvm'
        [predict_labels, ~, dec] = predict(label, data, model);

    otherwise
        error('Unknow tools for cross_validation.\n');
end

if model.Label(1) == 2
    dec = dec * (-1);
end

% call @eval_func
% label(label == 2) = -1;
% pd_labels = predict_labels;
% pd_labels(pd_labels == 2) = -1;
[acc, str] = eval_func(label,predict_labels,1); 
fprintf(str);
fprintf('\n');

end