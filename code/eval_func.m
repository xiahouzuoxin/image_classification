function [score,str] = eval_func(true_labels,predict_labels,type)
% 用于svm交叉验证的自定义评估函数
% type : 1,2,3,4,5
% 1:Accuracy = #true / #total
% 2:Precision = true_positive / (true_positive + false_positive) 
% 3:Recall = true_positive / (true_positive + false_negative) 
% 4:F-score = 2 * Precision * Recall / (Precision + Recall) 
% 5:
% BAC (Ballanced ACcuracy) = (Sensitivity + Specificity) / 2,
% where Sensitivity = true_positive / (true_positive + false_negative)
% and   Specificity = true_negative / (true_negative + false_positive) 

if nargin < 3
    type = 1;
end

% fg = 2;
% bg = 1;

% evaluate
eval_ok = 0;
while ~eval_ok
    switch type
        case 1  % Accuracy = #true / #total
            diff = int8(true_labels) - int8(predict_labels);
            n_diff = length(find(diff == 0));
            score = 100*n_diff / numel(true_labels);       
            str = sprintf('Accuracy = #true / #total = %s%%', num2str(score));

        case 2 % Precision = true_positive / (true_positive + false_positive)
            diff = int8(true_labels) - int8(predict_labels);
            ap = find(true_labels == 2);
            tp = numel(find(diff(ap) == 0));
    %         fp = numel(ap) - tp;
            score = 100 * tp / numel(ap);     
            str = sprintf('Precision = true_positive / (true_positive + false_positive) = %s',...
                num2str(score));

        case 3  % Recall = true_positive / (true_positive + false_negative) 
            diff = int8(true_labels) - int8(predict_labels);
            ap = find(true_labels == 2);
            tp = numel(find(diff(ap) == 0));
            af = find(true_labels == 1);
            fn = numel(find(diff(af) ~= 0));
            if (tp+fn) == 0
                score = 0;
            else
                score = 100 * tp / (tp + fn);
            end
            str = sprintf('Recall = true_positive / (true_positive + false_negative) = %s',...
                num2str(score));

        case 4 % F-score = 2 * Precision * Recall / (Precision + Recall) 
            diff = int8(true_labels) - int8(predict_labels);
            ap = find(true_labels == 2);
            tp = numel(find(diff(ap) == 0));
            if ap == 0
                Precision = 0;
            else
                Precision = tp / ap;  
            end
            af = find(true_labels == 1);
            fn = numel(find(diff(af) ~= 0));
            if (tp+fn) == 0
                Recall = 0;
            else
                Recall = tp / (tp + fn);
            end
            score = 100 * 2 * Precision * Recall / (Precision + Recall);
            str = sprintf('F-score = 2 * Precision * Recall / (Precision + Recall) = %s',...
                num2str(score));        

        case 5 % BAC (Ballanced ACcuracy) = (Sensitivity + Specificity) / 2
            diff = int8(true_labels) - int8(predict_labels);
            ap = find(true_labels == 2);
            tp = numel(find(diff(ap) == 0));
            fp = numel(ap) - tp;
            af = find(true_labels == 1);
            tn = numel(find(diff(af) == 0));   
            fn = numel(af) - tn;
            if (tp + fn) == 0
                Sensitivity = 0;
            else
                Sensitivity = tp / (tp + fn);
            end
            if (tn+fp) == 0
                Specificity = 0;
            else
                Specificity = tn / (tn + fp);
            end
            score = 100 * (Sensitivity + Specificity) / 2;
            str = sprintf('BAC (Ballanced ACcuracy) = (Sensitivity + Specificity) / 2 = %s',...
                num2str(score)); 

        otherwise
            type = 1;
            continue;
    end
    
    eval_ok = 1;
end
end
