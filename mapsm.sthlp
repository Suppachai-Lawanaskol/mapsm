{smcl}
{* *! version 16.0 29mar2024}{...}
{viewerdialog mapsm "dialog mapsm"}{...}
{viewerjumpto "Syntax" "mapsm##syntax"}{...}
{viewerjumpto "Description" "mapsm##description"}{...}
{viewerjumpto "Options" "mapsm##options"}{...}
{viewerjumpto "Examples" "mapsm##examples"}{...}
{viewerjumpto "Author" "mapsm##authors"}{...}

{p2col:{bf:mapsm}}Multiple arms propensity score matching 

{marker syntax}{...}
{title:Syntax}


{phang}{cmd:mapsm} {cmd:,} {opt gr:oup(varname)} [{opt s:eed(numlist) {opt n:ame(string) {opt s:ize(numlist)} {opt smd:(varlist)} {opt it:erate(numlist)} {opt replace:} {opt notab:le} {opt log:}]

{marker description}{...}
{title:Description}

{p 10 5 3}
	The mapsm (stands for multiple arms propensity score matching) command pairwise multiple propensity score matching cohort. For example, in the pairwise matching of two treatment arms, the participants will be matched within strata. Each stratum sorts the propensity score to the common strata by the probability of choosing each treatment arm. Multiple matching processes do in the same manner. We also include the ability to iterate to the fittest diagnostic balance parameters. The pre-treatment confounder set similarity will be measured with the mean standardized difference for the two treatment arms study and with the maximum standardized difference for the more than treatment arms study. 

{p 10 5 3}
	After iteration, we report the fittest value and the seeding number of the standardized difference fittest cohort. This command allows for the iterated imaginary matching cohort to measure the cohort and report the seeding number. Any user who needs a reproducible result can use the reported seeding number to re-match the same participants.  

{marker options}{...}
{title:Options}

{p2colset 10 25 25 3}{...}
{p2col:{opt gr:oup(varlist)}} Specify the treatment arms. Must be specify. {p_end}

{p2col:{opt s:eed(numlist)}} Specify the seeding number. Default is 1234. Commonly use to re-specify from imaginary matched cohort.{p_end}

{p2col:{opt n:ame(string)}} Specify the strata name. Default is strata. {p_end}

{p2col:{opt s:ize(numlist)}} Specify the strata size. Default is ten.{p_end}

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

{phang2}{stata use chocolate cyst.dta,clear: use chocolate cyst.dta,clear}

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
After the 200 iteration, the mean standardized difference is .011, and the seeding number is 1301. Now, we are matching. Without "notable" option. Pre-match and post-match cohort tabulations will be shown.

{phang2}{stata mapsm pscore, group(optype) seed(1301) name(block) replace: mapsm pscore, group(optype) seed(1301) name(block) replace}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mapsm} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 15 2: Scalars}{p_end}
{synopt:{cmd:r(seed)}} The fittest seeding number{p_end}
{synopt:{cmd:r(fittest)}} The fittest diagnostic balance (Mean/Max Standardized difference){p_end}
{synopt:{cmd:r(size)}} Strata size{p_end}


{p2col 5 15 15 2: Macros}{p_end}
{synopt:{cmd:r(strata)}} Strata variable name{p_end}
{synopt:{cmd:r(group)}} Treatment group variable name{p_end}

{p2col 5 15 15 2: Matrix}{p_end}
{synopt:{cmd:r(I)}}Iteration matrix{p_end}


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