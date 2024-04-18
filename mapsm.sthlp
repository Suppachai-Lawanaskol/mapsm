{smcl}
{* *! version 1.2 18april2024}{...}
{viewerdialog mapsm "dialog mapsm"}{...}
{viewerjumpto "Syntax" "mapsm##syntax"}{...}
{viewerjumpto "Description" "mapsm##description"}{...}
{viewerjumpto "Options" "mapsm##options"}{...}
{viewerjumpto "Examples" "mapsm##examples"}{...}
{viewerjumpto "Author" "mapsm##authors"}{...}

{p2col:{bf:mapsm}}Multiple arms propensity score matching 

{marker syntax}{...}
{title:Syntax}

{phang}{cmd:mapsm}{cmd:,} {opt gr:oup(varname)} [{opt s:eed(numlist)} {opt n:ame(string)} {opt si:ze(numlist)} {opt smd:(varlist)} {opt it:erate(numlist)} {opt replace:} {opt notab:le} {opt log:}]

{marker description}{...}
{title:Description}

{p 10 5 3}
	The mapsm command; stands for “Multiple Arms Propensity Score Matching”, matches the propensity scores predicted from binary logistic regression (or mutinomial logistic regression), which indicates the likeliness of choosing or being assigned into one among other treatment arms for each subject. In case of two-treatment arms study, the propensity sore (probability of 0-10) derived from binary logistic regression will be divided into 10 strata, 0-0.1, 0.1-0.2 until 0.9-1.0. Study subjects from either of the two arms will be sampled to match with the opposite arm within the same propensity score strata, with 1:1 ratio.

{p 10 5 3}
	In case of three or more arms, the propensity scores will be derived from multinomial logistic regression, yielding sets of propensity scores equal to number of arms, indicating the likeliness of choosing or being assigned to one among other treatment arms for each subject. Each set of the propensity scores will be divided into 10 strata similar to the two-treatment arms. Subjects from each arm within the same strata of the propensity score will be sampled to obtain a matched set of 1:1:1 ratio in case of three arms, and 1:1:1:1 in case of four arms, and so on.

{p 10 5 3}
	In order to obtain the most similar post-matched contrast groups, the command also rerun the matching process and reported the best post-matched contrast groups which has the best balance diagnostic property, such as standardized mean difference. The best seed-setting number (among those selected) will be reported in order to re-obtain the best post-matched cohort.

{marker options}{...}
{title:Options}

{p2colset 10 25 25 3}{...}
{p2col:{opt gr:oup(varlist)}} Specify the treatment arms. Must be specify. {p_end}

{p2col:{opt s:eed(numlist)}} Specify the seeding number. Default is 1234. Commonly use to re-specify from imaginary matched cohort.{p_end}

{p2col:{opt n:ame(string)}} Specify the strata name. Default is strata. {p_end}

{p2col:{opt si:ze(numlist)}} Specify the strata size. Default is ten.{p_end}

{p2col:{opt smd:(varlist)}} Specify the pre-treatment confounder from propensity score model. Optional.{p_end}

{p2col:{opt it:erate(numlist)}} In case of smd option is specified, the iteration round should be determined. Default is 100. {p_end}

{p2col:{opt replace:}} Replace the existing strata variable. Commonly use to overwrite the strata variable from imaginary cohort. {p_end}

{p2col:{opt notab:le}} Suppress the strata tabulation across the treament arms. {p_end}

{p2col:{opt log:}} Report the iteration seeding number and the imaginary cohort mean or maximum standardized difference. {p_end}
{p2colreset}{...}

{marker examples}{...}
{title:Examples}

{p 5 5 3}
Import Chocolate cyst example dataset. The surgeon was choosing between the laparoscopic approach and laparotomy approach to diagnose, stage, and eradicate the endometrioma.{p_end}

{phang2}{stata `"use https://raw.githubusercontent.com/Suppachai-Lawanaskol/mapsm/main/chocolate_cyst.dta,clear"': Download chocolate_cyst.dta}

{p 5 5 3}
Estimate propensity score with binary logistic regression{p_end}

{phang2}{stata logit optype age wt bmi bilat size: logit optype age wt bmi i.bilat size}

{p 5 5 3}
Predict the probability. (propensity score){p_end}

{phang2}{stata predict pscore: predict pscore}

{p 5 5 3}
Create an imaginary matched cohort and record the seeding number. Report the balance diagnostic fittest value and its seeding number. Input the probability variable. Binary treatment group. Specify initiation seeding number to 1234. Strata variable name, "Block". Strata size of 10. The iterate round of 200. The Covariates accountable for the balance diagnostic are Age, Body weight, Body mass index, Bilaterality, and Preoperative endometriotic diameter. Strata tabulation across the treatment groups is suppressed.{p_end}

{phang2}{stata mapsm pscore, group(optype) seed(1234) name(block) size(10) smd(age wt bmi i.bilat size) iterate(200) notab: mapsm pscore, group(optype) seed(1234) name(block) size(10) smd(age wt bmi i.bilat size) iterate(200) notab}

{p 5 5 3}
After the 200 iterations, the mean standardized difference is .011, and the seeding number is 1301. Now, we are matching. Without "notable" option. Pre-match and post-match cohort tabulations will be shown.

{phang2}{stata mapsm pscore, group(optype) seed(1301) name(block) replace: mapsm pscore, group(optype) seed(1301) name(block) replace}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mapsm} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 15 2: Scalars}{p_end}
{synopt:{cmd:r(seed)}} The best seeding number{p_end}
{synopt:{cmd:r(smallest)}} The smallest diagnostic balance (Mean/Max Standardized difference){p_end}
{synopt:{cmd:r(size)}} Strata size{p_end}


{p2col 5 15 15 2: Macros}{p_end}
{synopt:{cmd:r(strata)}} Strata variable name{p_end}
{synopt:{cmd:r(group)}} Treatment group variable name{p_end}

{p2col 5 15 15 2: Matrix}{p_end}
{synopt:{cmd:r(I)}} Iteration matrix{p_end}


{marker author}{...}
{title:Authors}

{p 5 5 3}
Suppachai Lawanaskol, MD{p_end}
{p 5 5 3}
Chaiprakarn hospital, Chiang Mai, Thailand{p_end}
{p 5 5 3}
Email suppachai.lawanaskol@gmail.com{p_end}

{p 5 5 3}
Phichayut Phinyo, MD, PhD{p_end}
{p 5 5 3}
Center of Clinical Epidemiology and Clinical Statistics, Faculty of Medicine, Chiang Mai University, Chiang Mai, Thailand{p_end}
{p 5 5 3}
Email phichayut.phinyo@gmail.com{p_end}

{p 5 5 3}
Jayanton Patumanond, MD, DSc{p_end}
{p 5 5 3}
Center of Clinical Epidemiology and Clinical Statistics, Faculty of Medicine, Chiang Mai University, Chiang Mai, Thailand{p_end}
{p 5 5 3}
Email jpatumanond@gmail.com{p_end}
