function [BIS,BISattn,BISmotor,BISnonplan] = calculateBISScores(rawresponses)

% reference: Factor structure of the Barratt impulsiveness scale. Patton JH, Stanford MS, and Barratt ES (1995)
% Journal of Clinical Psychology, 51, 768-774.
% http://www.impulsivity.org/measurement/bis11

% scoring info found here:
% https://en.wikipedia.org/wiki/Barratt_Impulsiveness_Scale#Scoring


% define subscale items


% which items are reverse scored
reverseArr = [1 7 8 9 10 12 13 15 20 29 30];


% second-order factors
attnArr = [5 6 9 11 20 24 26 28];
motorArr = [2 3 4 16 17 19 21 22 23 25 30];
nonplanArr = [1 7 8 10 12 13 14 15 18 27 29];


%%

BIS = nan;
BISattn = nan;
BISmotor = nan;
BISnonplan = nan;

if size(rawresponses,2)~=30
    error('hold up - there must be raw data from 30 questions in each row of raw input.');
    
else
    
    rawresponses(reverseArr) = 5-rawresponses(reverseArr); % reverse score for certain items
    
    % occasionally, a subject will leave 1 question blank. If
    % that's the case, fill in that response with the median response from all the other questions
    if ~isempty(find(isnan(rawresponses)))
        rawresponses(isnan(rawresponses))=nanmedian(rawresponses);
    end
    
    BIS = sum(rawresponses);
    BISattn = sum(rawresponses(attnArr));
    BISmotor = sum(rawresponses(motorArr));
    BISnonplan = sum(rawresponses(nonplanArr));
    
    
end
% 


