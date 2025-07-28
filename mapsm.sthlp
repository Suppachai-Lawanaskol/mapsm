{smcl}
{* *! version 1.4 18July2025}{...}
{viewerdialog mapsm "dialog mapsm"}{...}
{viewerjumpto "Syntax" "mapsm##syntax"}{...}
{viewerjumpto "Description" "mapsm##description"}{...}
{viewerjumpto "Options" "mapsm##options"}{...}
{viewerjumpto "Examples" "mapsm##examples"}{...}
{viewerjumpto "Author" "mapsm##authors"}{...}

{p2col:{bf:mapsm}}Multiple arms propensity score matching 

{marker syntax}{...}
{title:Syntax}

{phang}{cmd:mapsm} {varlist} {ifin} {cmd:,} {opt g:roup(varname)} [{opt se:ed(integer)} {opt n:ame(string)} {opt si:ze(integer)} {opt sm:d(varlist)} {opt it:erate(integer)} {opt r:eplace} {opt notab:le} {opt l:og} {opt a:ppend}]

{marker description}{...}
{title:Description}

{p 10 5 3}
The {cmd:mapsm} command; stands for “Multiple Arms Propensity Score Matching”, matches the propensity scores
 predicted from binary logistic regression (or multinomial logistic regression), which indicates the
 likeliness of choosing or being assigned to one among other treatment arms for each subject. In case
 of two-treatment arms study, the propensity score (probability of 0-1.0) derived from binary logistic
 regression will be divided into 10 strata, 0-0.1, 0.1-0.2 until 0.9-1.0. Study subjects from either
 of the two arms will be sampled to match with the opposite arm within the same propensity score
 strata, with 1:1 ratio.

{p 10 5 3}
In case of three or more arms, the propensity scores will be derived from multinomial logistic 
regression, yielding sets of propensity scores equal to number of arms, indicating the likeliness of 
choosing or being assigned to one among other treatment arms for each subject. Each set of the
 propensity scores will be divided into 10 strata similar to the two-treatment arms. Subjects from
 each arm within the same strata of the propensity score will be sampled to obtain a matched set of
 1:1:1 ratio in case of three arms, and 1:1:1:1 in case of four arms, and so on.

{p 10 5 3}
In order to obtain the most similar post-matched contrast groups, the command also rerun the matching
 process and reported the best post-matched contrast groups which has the best balance diagnostic 
property, such as standardized mean difference. The best seed-setting number (among those selected)
 will be reported in order to re-obtain the best post-matched cohort. Any number of treatment arms fewer than ten can be matched using simple pairwise comparisons or by running an iterative process to obtain the best seed number for the actual matching. 

{p 10 5 3}
Any probabilities specified in the {varlist} will be automatically constrained between 0 and 1, as required by the definition of probability. This situation may occur when the probabilities are derived from a non-logit link function (e.g., identity or log link). 

{p 10 5 3}
After actual matching with the append option, the original dataset (pre-match cohort) will be placed next to the last observation of the post-match cohort. The similarity between treatment arms can be visualized using a kernel density plot of the propensity score, especially when there are more than two treatment arms. By design, love plots and histograms are not supported for visualization in this context. To illustrate this, an example command has been provided in the example section of this help file.

{marker options}{...}
{title:Options}

{p2colset 10 30 31 0}{...}
{p2col:{opt g:roup(varlist)}} Specify the treatment arms. Must be specified. {p_end}

{p2col:{opt se:ed(numlist)}} Specify the initial seeding number. Default is 1234. Commonly use to re-specify after dryrun of imaginary matched cohort.{p_end}

{p2col:{opt n:ame(string)}} Specify the strata variable name. Default is strata. {p_end}

{p2col:{opt si:ze(numlist)}} Specify the total strata number. Default is ten.{p_end}

{p2col:{opt sm:d(varlist)}} Specify the pre-treatment confounder from propensity score model. Optional.{p_end}

{p2col:{opt it:erate(numlist)}} In case of smd option is specified, the iteration round should be 
determined. Default is 100. Maximum iteration round is restricted due to maximum matrix size setting (800 for Basic edition). {p_end}

{p2col:{opt r:eplace}} Replace the existing strata variable. Commonly use to overwrite the strata 
variable from imaginary cohort. {p_end}

{p2col:{opt notab:le}} Suppress the strata tabulation across the treatment arms. {p_end}

{p2col:{opt l:og}} Report the iteration seeding number and the postmatch mean or maximum 
absolute standardized difference. {p_end}

{p2col:{opt a:ppend}} Append the pre-matched cohort to the post-matched dataset. An {cmd:append} variable is created to indicate the original cohort, placed after the last observation of the matched dataset, for use in balance diagnostics and graphical illustration.{p_end} 
{p2colreset}{...}

{marker examples}{...}
{title:Examples}

{p2colset 10 30 31 0}{...}
{p2col:{opt Two arms: }} {p_end}
{p2colreset}{...}

{p 5 5 3}
Import the chocolate cyst example dataset. In this example, a surgeon chooses between the laparoscopic approach (minimally invasive surgery, MIS) and the laparotomy approach (open surgery) to diagnose, stage, and remove the endometrioma.{p_end}

{phang2}{stata `"use https://raw.githubusercontent.com/Suppachai-Lawanaskol/mapsm/main/chocolate_cyst.dta,clear"': Download chocolate_cyst.dta}

{p 5 5 3}
Estimate the propensity score by fitting a binary logistic regression model using treatment assignment as the dependent variable.{p_end}

{phang2}{stata logit optype age wt bmi bilat size: logit optype age wt bmi i.bilat size}

{p 5 5 3}
Use the fitted logistic regression model to predict the probability of treatment assignment for each subject (i.e., the propensity score). This step should be executed immediately after the logistic regression command.{p_end}

{phang2}{stata predict pscore: predict pscore}

{p 5 5 3}
Create an imaginary matched cohort and record the seeding number. Report the smallest balance diagnostic value along with its corresponding seeding number. Input the probability variable. The treatment groups are binary. Set the initial seeding number to {cmd:1234}. The strata variable is named {cmd:"Block"}, with a strata size of {cmd:10}, and an iteration count of {cmd:200}. The covariates considered for the balance diagnostic are {bf}age, body weight, body mass index, bilaterality, and preoperative endometriotic diameter{sf}. Strata tabulation across treatment groups is suppressed.

{phang2}{stata mapsm pscore, group(optype) seed(1234) name(block) size(10) smd(age wt bmi i.bilat size) iterate(200) notab: mapsm pscore, group(optype) seed(1234) name(block) size(10) smd(age wt bmi i.bilat size) iterate(200) notab}

{p 5 5 3}
After 200 iterations, the mean standardized difference is {cmd:.011}, and the corresponding seeding number is {cmd:1301}. Now, proceed with matching. Without the {cmd:"notable"} option, tabulations of the pre-match and post-match cohorts will be displayed now.

{phang2}{stata mapsm pscore, group(optype) seed(1301) name(block) replace: mapsm pscore, group(optype) seed(1301) name(block) replace}

{p2colset 10 30 31 0}{...}
{p2col:{opt Three arms: }} {p_end}
{p2colreset}{...}

{p 5 5 3}
Import the coronary artery bypass grafting (CABG) example dataset. In this example, a surgeon chooses among conventional CABG, off-pump CABG (OPCAB), and on-pump beating-heart CABG (ONBHCAB). The study focuses on comparing the short- and long-term outcomes of these different surgical techniques.

{phang2}{stata `"use https://raw.githubusercontent.com/Suppachai-Lawanaskol/mapsm/main/cabg.dta,clear"': Download cabg.dta}

{p 5 5 3}
Use multinomial logistic regression to estimate the propensity scores for subjects across multiple treatment groups.{p_end}

{phang2}{stata mlogit sxtype sex age i.nyfc i.ccs aceiarb asa clopidogrel ckd5esrd i.cadtype lm: mlogit sxtype sex age i.nyfc i.ccs aceiarb asa clopidogrel ckd5esrd i.cadtype lm}

{p 5 5 3}
Predict the probability of assignment to each treatment group (i.e., the propensity scores).{p_end}

{phang2}{stata predict cabg opcab onbhcab: predict cabg opcab onbhcab}

{p 5 5 3}
Create an imaginary matched cohort and record the seeding number. Report the smallest balance diagnostic value along with its corresponding seeding number. Input the probability variable. The treatment groups are multiple. Set the initial seeding number to {cmd:1234}. The strata variable is named {cmd:"Block"}, with a strata size of {cmd:10} and an iteration count of {cmd:50}. The covariates considered for the balance diagnostic are {bf}sex, age, New York Heart Association (NYHA) functional class, Canadian Cardiovascular Society (CCS) angina grade, ACEI/ARB, aspirin, clopidogrel, chronic kidney disease stage V, coronary artery disease type (e.g., single-, double-, or triple-vessel disease), and left main disease{sf}. Strata tabulation across treatment groups is suppressed.{p_end}

{phang2}{stata mapsm cabg opcab onbhcab, group(sxtype) seed(1234) name(block) size(10) smd(sex age i.nyfc i.ccs aceiarb asa clopidogrel ckd5esrd i.cadtype lm) iterate(50) notab}

{p 5 5 3}
After 50 iterations, the maximum standardized difference is {cmd:0.0661}, and the corresponding seeding number is {cmd:1255}. Now, proceed with matching. Without the {cmd:"notable"} option, tabulations of the pre-match and post-match cohorts will be displayed. With the {cmd:replace} option, Stata will overwrite the existing strata variable.{p_end} 

{phang2}{stata mapsm cabg opcab onbhcab, group(sxtype) seed(1255) name(block) size(10) replace: mapsm cabg opcab onbhcab, group(sxtype) seed(1255) name(block) size(10) replace}{p_end}

{p 5 5 3}In actual matching, report the balance diagnostics by including the {cmd:smd} and {cmd:log} options.{p_end}

{phang2}{stata mapsm cabg opcab onbhcab, group(sxtype) smd(sex age i.nyfc i.ccs aceiarb asa clopidogrel ckd5esrd i.cadtype lm) log}{p_end}

{p 5 5 3}In actual matching, the original cohort is appended after the last observation of the matched cohort. A variable named {cmd:append} is generated by default to indicate the cohort type. For subsequent balance diagnostics and illustration, use the standardized difference command with an {cmd:if} condition based on the value of the {cmd:append} variable.{p_end}

{phang2}{stata mapsm cabg opcab onbhcab, group(sxtype) append}{p_end}

{p 5 5 3}To visualize the original cohort (append == 1) compared to the postmatch cohort (append == 0), use kernel density line plots for each group.{p_end}

{phang2}{stata twoway (kdensity cabg if sx==0)(kdensity cabg if sx==1)(kdensity cabg if sx==2)(kdensity opcab if sx==0)(kdensity opcab if sx==1)(kdensity opcab if sx==2)(kdensity onbhcab if sx==0)(kdensity onbhcab if sx==1)(kdensity onbhcab if sx==2) if append}{p_end}

{phang2}{stata twoway (kdensity cabg if sx==0)(kdensity cabg if sx==1)(kdensity cabg if sx==2)(kdensity opcab if sx==0)(kdensity opcab if sx==1)(kdensity opcab if sx==2)(kdensity onbhcab if sx==0)(kdensity onbhcab if sx==1)(kdensity onbhcab if sx==2) if append}{p_end}


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
Phichayut Phinyo, MD, MSc, PhD{p_end}
{p 5 5 3}
Center of Clinical Epidemiology and Clinical Statistics, Faculty of Medicine, Chiang Mai University, Chiang Mai, Thailand{p_end}
{p 5 5 3}
Email phichayutphinyo@gmail.com{p_end}

{p 5 5 3}
Jayanton Patumanond, MD, DSc{p_end}
{p 5 5 3}
Clinical Epidemiology Unit, Faculty of Medicine, Naresuan University, Phitsanulok, Thailand{p_end}
{p 5 5 3}
Email jpatumanond@gmail.com{p_end}
