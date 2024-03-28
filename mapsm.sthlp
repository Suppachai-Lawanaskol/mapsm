{smcl}
{* *! version 16.0 29mar2024}{...}
{viewerdialog mapsm "dialog mapsm"}{...}
{viewerjumpto "Syntax" "mapsm##syntax"}{...}
{viewerjumpto "Description" "mapsm##description"}{...}
{viewerjumpto "Options" "mapsm##options"}{...}
{viewerjumpto "Examples" "mapsm##examples"}{...}
{viewerjumpto "Author" "mapsm##authors"}{...}

{p2col:{bf:bta2score}}Multiple arms propensity score matching 

{marker syntax}{...}
{title:Syntax}


{phang}{cmd:mapsm} {cmd:,} {opt gr:oup(varname)} [{opt s:eed(numlist) {opt n:ame(string) {opt s:ize(numlist)} {opt smd:(varlist)} {opt it:erate(numlist)} {opt replace:} {opt notab:le} {opt log:}]

{marker description}{...}
{title:Description}

{p 10 5 3}
	The mapsm (stands for mulitple arms propensity score matching) command pairwise multiple propensity score matching cohort. Like in the pairwise matching in two treatment arms, the participants will be matched within strata. Each stratum sort the propensity score to the common strata by probability to choose or to be choose each treatment arms. Multiple matching process do in the same manner. We also include the ability of iteration to the fittest diagnostic balance parameters. The similarity of the pre-treament confounder set will be measured with the mean standardized difference for the two treatment arms study and with the maximum standardized difference for the more than treatment arms study. 

{p 10 5 3}
	After iteration, we report the fittest value and the seeding number of the standardized difference fittest cohort. This command allow for the iterated imaginary matching cohort to measure the cohort and report the seeding number. Any user need for the reproducible result can use the reported seeding number to re-matched the same participants. 

{marker options}{...}
{title:Options}
{opt s:eed(numlist)} {opt n:ame(string)} {opt s:ize(numlist)} {opt smd:(varlist)} {opt it:erate(numlist)} {opt replace:} {opt notab:le} {opt log:}

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
Import Chocolate cyst example dataset. Choosing between the laparoscopic approach and laparotomy approach to diagnose, staging, and eradicate the endometrioma.

{phang2}{stata use chocolate cyst.dta,clear: use chocolate cyst.dta,clear}

{p 5 5 3}
Estimate propensity score with binary logistic regression

{phang2}{stata logit optype age wt bmi bilat size: logit optype age wt bmi i.bilat size}

{p 5 5 3}
Predict the probability (propensity score)

{phang2}{stata predict pscore: predict pscore}

{p 5 5 3}
Creat imaginary matched cohort and record the seeding number. Report the balance diagnostic fittest value and its seeding number. Input the probability variable. Binary treament group. Specify initiation seeding number to 1234. Strata variable name, "Block". Strata size of 10.  Iterate round was set to 200. Covariates which accountable for the balance diagnostic is Age, Body weight, Body mass index, Bilaterality, and Preoperative endometricotic diameter. Strata tabulation across treament groups is suppressed.

{phang2}{stata mapsm pscore, group(optype) seed(1234) name(block) size(10) smd(age wt bmi i.bilat size) iterate(50) notab: 
mapsm pscore, group(optype) seed(1234) name(block) size(10) smd(age wt bmi i.bilat size) iterate(200) notab}

{p 5 5 3}After the 200-iteration, the mean standardized difference is .011 and the seeding number is 1301. Now, we are actually matching. Without notab option. Pre-match and post-match cohort tabulation are showed.

{phang2}{stata mapsm pscore, group(optype) seed(1301) name(block) iterate(50) replace: mapsm pscore, group(optype) seed(1301) name(block) iterate(50) replace}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:bta2score} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 15 2: Scalars}{p_end}
{synopt:{cmd:r(cstat)}}Harrell's C-statistic{p_end}
{synopt:{cmd:r(dstat)}}Somer's D-statistic{p_end}
{synopt:{cmd:r(aic)}}Akaike's information criterion{p_end}
{synopt:{cmd:r(bic)}}Bayesian information criterion{p_end}
{synopt:{cmd:r(gof)}}Hosmer-Lemeshow Goodness-of-fit p-value{p_end}
{synopt:{cmd:r(rsquare)}}R-square{p_end}

{p2col 5 15 15 2: Macros}{p_end}
{synopt:{cmd:r(name)}}Score name{p_end}
{synopt:{cmd:r(endpoint)}}Endpoint variable{p_end}

{p2col 5 15 15 2: Matrix}{p_end}
{synopt:{cmd:r(coef)}}Original coefficient matrix{p_end}


{marker author}{...}
{title:Authors}

{p 5 5 3}
Suppachai Lawanaskol, MD{p_end}
{p 5 5 3}
Chaiprakarn hospital, Chiang Mai, Thailand{p_end}
{p 5 5 3}
Email suppachai.lawanaskol@gmail.com{p_end}

{p 5 5 3}
Jayanton Patumanond, MD, DSc{p_end}
{p 5 5 3}
Center of Clinical Epidemiology and Clinical Statistics, Faculty of Medicine, Chiang Mai University, Chiang Mai, Thailand{p_end}
{p 5 5 3}
Email jpatumanond@gmail.com{p_end}
