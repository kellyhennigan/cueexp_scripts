%% estimate discounting parameters k based on the Kirby procedure, described here:
% https://www.phenxtoolkit.org/index.php?pageLink=browse.protocoldetails&id=530301

function [k, nInconsistent, data] = FitK_Kirby(SS,LL,delay,choice)

% INPUTS: the following column vectors:
%     SS - magntiude of the sooner option
%     LL - magntude of the later option
%     delay - time delay between options
%     choice - 1s indicating the SS option and 0s indicating the LL option
%
% OUTPUTS:
%     k - estimate of hyperbolic discounting parameter k following the
%         Kirby procedure.
%     nInconsistent - number of choices made that are inconsistent with k
%     data - data w/trial k estimates added as a column & rows sorted by k
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% explicitly add vector of delays=0 for SS, if not given
if size(delay,2)==1
    delay = [zeros(size(delay,1),1) delay];
end

% for each set of options, determine the hyperbolic discounting rate that 
% associated with indifference for the SS and LL
trial_k=(1./SS-1./LL)./(delay(:,2)./LL-delay(:,1)./SS);
% trial_k = ((LL./SS)-1)./delay;

data = [SS,LL,delay,choice];
choice_col = size(data,2); k_col = size(data,2)+1; % index of which columns have choice & k vals

data(:,k_col) = trial_k; % add k to data

% omit any trials with 'nan' choices
omitIdx=find(isnan(choice));
if ~isempty(omitIdx)
    fprintf(['\n omitting ',num2str(length(omitIdx)),' trials with nan responses...\n'])
    data(omitIdx,:)=[];
end


%% estimate k using the Kirby method

% procedure based on info found here:
% from https://www.phenxtoolkit.org/index.php?pageLink=browse.protocoldetails&id=530301

data = sortrows(data,k_col); % add k to data & sort by k

nSSChoices = sum(data(:,choice_col)); % choice switch point

% if they always chose the SS, set k to the value in the last row
if nSSChoices==size(data,1)
    k = data(nSSChoices,k_col);
    
    % else if they never chose the SS, set k to the value in the first row
elseif  (nSSChoices==0)
    k = data(1,k_col);
    
    % else set k to the mean of the rows at the switch point
else
    k = mean(data(nSSChoices:nSSChoices+1,k_col));
    
end

% % now set inf k values to the max k val
% if isinf(k)
%     k = max(trial_k(~isinf(trial_k)));
% end

nInconsistent = length(find(data(data(:,k_col)>k,choice_col)==1)); % # of inconsistent SS choices
nInconsistent = nInconsistent + length(find(data(data(:,k_col)<k,choice_col)~=1)); % plus # of LL choices





