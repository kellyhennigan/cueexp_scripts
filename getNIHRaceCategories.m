function nihcat = getNIHRaceCategories(cuecat)
% -------------------------------------------------------------------------
% usage: function to transform self-reported race from cue data to NIH race categories
% 
% INPUT:
%   cuecat - output from "how would you classify yourself" question on
%   qualtrics survey

% 
% OUTPUT:
%   nihcat - nih categoeries of race/ethinicity data (see below for categories)
% 
% NOTES:
% 
% NIH guidelines found here: 
% https://grants.nih.gov/grants/guide/notice-files/NOT-OD-15-089.html
% 
% 1) American Indian or Alaska Native. A person having origins in any of
% the original peoples of North and South America (including Central
% America), and who maintains tribal affiliation or community attachment.

% 2) Asian. A person having origins in any of the original peoples of the
% Far East, Southeast Asia, or the Indian subcontinent including, for
% example, Cambodia, China, India, Japan, Korea, Malaysia, Pakistan, the
% Philippine Islands, Thailand, and Vietnam.

% 3) Black or African American. A person having origins in any of the black
% racial groups of Africa. Terms such as "Haitian" or "Negro" can be used
% in addition to "Black or African American."

% 4) Hispanic or Latino. A person of Cuban, Mexican, Puerto Rican, Cuban,
% South or Central American, or other Spanish culture or origin, regardless
% of race. The term, "Spanish origin," can be used in addition to "Hispanic
% or Latino."

% 5) Native Hawaiian or Other Pacific Islander. A person having origins in
% any of the original peoples of Hawaii, Guam, Samoa, or other Pacific
% Islands.

% 6) White. A person having origins in any of the original peoples of
% Europe, the Middle East, or North Africa.

% 7) multiracial (my category) - people who identify with 2 or more of the
% above categories

% 8) decline to state - no response

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% race/ethnicity categories from qualtrics data:

%     1= Arab
%     2= Asian/Pacific Islander
%     3= Black
%     4= Caucasian/White
%     5= Hispanic
%     6= Indigenous or Aboriginal
%     7= Latino
%     8= Multiracial
%     9= Would rather not say
%     10 - fill in


%% 

nihcat = nan(numel(cuecat),1);

nihcat(cuecat==1)=2;
nihcat(cuecat==2)=2;
nihcat(cuecat==3)=3;
nihcat(cuecat==4)=6;
nihcat(cuecat==5)=4;
nihcat(cuecat==6)=1;
nihcat(cuecat==7)=4;
nihcat(cuecat==8)=7;
nihcat(cuecat==9)=8;

