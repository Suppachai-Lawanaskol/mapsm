*! version 1.5 7Sep2025
***Suppachai Lawanaskol, MD***
***Phichayut Phinyo, MD, MSc, PhD***
***Jayanton Patumanond, MD, DSc***
program define mapsm, rclass
	version 16.0
	syntax varlist (min=1 max=10 numeric) [if] [in] [, Group(varlist fv) SEed(int 1234) Name(string asis) SIze(int 10) SMd(string asis) ITerate(int 0) Replace NOTABle Log Append]

	**Drop previous returning object**
	capture scalar drop r(seed)
	capture scalar drop r(smallest)
	capture scalar drop r(size)
	capture local drop r(strata)
	capture local drop r(group)
	capture matrix drop r(I)
	
	**Marksample on touse**
	marksample touse
	
	**Check the arms are equal to the predicted probability from the propensity score model**
	
	qui tab `group' if `touse'
	scalar n_group=r(r)
	if `=scalar(n_group)'!=`: word count `varlist'' & `=scalar(n_group)'>2{
		di as error "The number of propensity score variables are not equal to the number of treatment arms"
	}
	
	**Generate the strata name**
	
	if "`name'"==""{
		local name strata
	}
	
	**Drop all previous returning object**
	
	capture scalar drop std_represent
	capture matrix drop std
	
	**Replace the previous strata variable**
	
	if "`replace'"!=""{
		capture drop `name'
		capture drop append
	}
	
	**If Iteration option was selected, SMD should be specify,and should identical to the propensity score model**
	
	if `iterate'>0 & "`smd'"==""{
		di as error "Please identify the pre-treament confounder"
	}
	if `iterate'>0 & "`seed'"!=""{
		di in yellow "The iteration process start at initial seeding number of `seed'"
		capture which stddiff
		if _rc==111{
			ssc install stddiff,replace
			di "stddiff package need to be installed"
		}
	}
	if "`group'"==""{
		di as error "Please specify the treatment arms"
	}
	if `iterate'>0{
		di in yellow "The iteration round was set to `iterate'"
		capture which stddiff
		if _rc==111{
			ssc install stddiff,replace
			di "stddiff package need to be installed"
		}
	}
	
	**Define the step**
	
	qui generate `name'="" if `touse'
	scalar step=1/`size'
	
	**Pre-matching diagnostic SMD Mean / SMD Max**
	
	qui tab `group' if `touse'
	scalar arms=r(r)-1
	if `=scalar(arms)'==0{
		display as error "The group variable must contain more than one group. Please specify the treatment arms."
	}
	
	**Two treament arms**
	
	if "`smd'"!="" & `=scalar(arms)'==1 {
		scalar std_accum=0
		qui stddiff `smd' if `touse' ,by(`group') 
		qui mat std=r(stddiff)
		forvalues e=1/`=rowsof(std)'{
			if std[`e',1]==.{
				mat std[`e',1]=0
			}
			scalar std_accum=`=scalar(std_accum)'+abs(std[`e',1])
		}
		scalar std_represent=`=scalar(std_accum)'/`=rowsof(std)'
		
		**Show iteration log**
		
		if "`log'"!=""{
			di in green "Pre match SMD Mean = " in yellow `=scalar(std_represent)'
		}
	}
	
	**More than two treatment arms**
	
	else if "`smd'"!="" & `=scalar(arms)'>1{
		capture drop `group'_*
		qui tab `group' if `touse' ,gen(`group'_)
		scalar std_max=0
		forvalues i=0/`=scalar(arms)'{
			forvalues j=1/`=scalar(arms)'{
				if `i'<`j'{
					qui stddiff `smd' if (`group'==`i' | `group'==`j') & `touse' ,by(`group') abs
					qui mat std=r(stddiff)
					forvalues k=1/`=rowsof(std)'{
						if std[`k',1]==.{
							mat std[`k',1]=0
						}
						scalar std_max=max(`=scalar(std_max)',abs(std[`k',1]))
					}
				}
			}
		}
		scalar std_represent=`=scalar(std_max)'
		if "`log'"!=""{
			di in green "Pre match SMD Max = " in yellow `=scalar(std_represent)'
		}
	}
	
	**Alarm the too multiple groups**
	
	if `=scalar(arms)'>4{
		display "More than four multiple arms matching resulting in the low power of postmatch cohort"
	}
	
	**Check the 0-1 boundary of propensity score wheather the binary arms or more**
	
	foreach pred_var in `varlist' {
		qui sum `pred_var' if `touse'
		if r(max)>0.9999999 | r(min)<0.0000001{
			qui replace `pred_var'=0.9999999 if `pred_var'>0.9999999 & `touse'
			qui replace `pred_var'=0.0000001 if `pred_var'<0.0000001 & `touse'
			display "`pred_var' that were out of bounds were restricted between 0 and 1."
		}
	}
	
	**Generate strata pattern from predict probability**
	
	foreach pred_var in `varlist' {
		qui capture drop `pred_var'_cut
		qui egen `pred_var'_cut=cut(`pred_var') if `touse',at(0(`=scalar(step)')1)
		qui capture drop `pred_var'_int
		qui gen `pred_var'_int=`pred_var'_cut*`size' if `touse'
		qui tostring `pred_var'_int,replace
		qui replace `name'=`name'+`pred_var'_int if `touse'
	}
	qui destring `name',replace
	
	**Define scalar in the matching process**
	
	scalar seed=`seed'
	scalar n=_N
	qui tab `group' if `touse'
	scalar arms=r(r)-1
	qui tab `name' if `touse',matrow(s)
	qui mat li s
	scalar pattern=r(r)
	
	**Show the strata tabulation across treament groups** 
	
	if "`notable'"==""{
		tab `name' `group' if `touse'
	} 
	scalar seed_final=`=scalar(seed)'+`iterate'-1
	
	**Iteration**
	
	if `iterate'>0{
		
		**Define the Matrix that contain seed and fitting value for each seed**
		
		mat def I=J(`iterate',2,.)
		forvalues h=`=scalar(seed)'/`=scalar(seed_final)'{
			if "`log'"==""{
				_dots `=scalar(seed_final)'-`h' 0
			}
			preserve
			forvalues p=0/`=scalar(pattern)'{
				scalar min=`=scalar(n)'
				forvalues a=0/`=scalar(arms)'{
					qui count if `name'==s[`p',1] & `group'==`a' & `touse'
					scalar n_`a'=r(N)
					qui scalar min="`=scalar(min)'"+","+"`=scalar(n_`a')'"
				}
				scalar min_num=min(`=scalar(min)')
				forvalues a=0/`=scalar(arms)'{
					set seed `h'
					qui sample `=scalar(min_num)' if `name'==s[`p',1] & `group'==`a' & `touse',count
				}
			}
			
			**Post matching diagnostic SMD/SMD Max**
			
			qui tab `group'
			scalar arms=r(r)-1
			
			**Two treament arms**
			
			if "`smd'"!="" & `=scalar(arms)'==1 {
				qui stddiff `smd' if `touse',by(`group')
				
				**STDDIFF mean**
				scalar std_accum=0
				qui mat std=r(stddiff)
					forvalues e=1/`=rowsof(std)'{
						if std[`e',1]==.{
							mat std[`e',1]=0
						}
					scalar std_accum=`=scalar(std_accum)'+abs(std[`e',1])
					}
				scalar std_represent=`=scalar(std_accum)'/`=rowsof(std)'
			}
			
			**More than two treament arms**
			
			else if "`smd'"!="" & `=scalar(arms)'>1{
				
				**pairwise STDDIFF MAX**
				
				capture drop `group'_*
				qui tab `group' if `touse',gen(`group'_)
				scalar std_max=0
				forvalues i=0/`=scalar(arms)'{
					forvalues j=1/`=scalar(arms)'{
						if `i'<`j'{
							qui stddiff `smd' if (`group'==`i' | `group'==`j') & `touse' ,by(`group')
							qui mat std=r(stddiff)
							forvalues k=1/`=rowsof(std)'{
								if std[`k',1]==.{
									std[`k',1]=0
								}
								scalar std_max=max(`=scalar(std_max)',abs(std[`k',1]))
							}
						}
					}
				}
				scalar std_represent=`=scalar(std_max)'
			}
			restore
			
			**Report the seed in the first column and fitting value in the second column**
			
			scalar iterate=`h'-`=scalar(seed)'+1
			qui mat I[`=scalar(iterate)',1]=`=scalar(iterate)'
			qui mat I[`=scalar(iterate)',2]=`=scalar(std_represent)'
			
			**Tabulation should be quite if iterate**
			
			if "`smd'"!="" & `=scalar(arms)'==1 {
				**Show iteration log**
				if "`log'"!=""{
					di in green "SMD Mean at seed `h' =" in yellow %9.6f `=scalar(std_represent)'
				}
			}
			else if "`smd'"!="" & `=scalar(arms)'>1{
				**Show iteration log**
				if "`log'"!=""{
					di in green "SMD Max at seed `h' =" in yellow %9.6f `=scalar(std_represent)'
				}
			}
			
		}		
		
		**Extract maximum SMD_max/SMD and report the iteration seed**
		
		scalar fittest_value=1
		forvalues m=1/`iterate'{
			scalar fittest_value=min(`=scalar(fittest_value)',I[`m',2])
		}
		
		**Display the smallest mean/maximum pairwise SMD**
		
		di ""
		if `=scalar(arms)'==1{
			di in green "Smallest mean pairwise SMD" _col(28)"=" in yellow _col(30) %6.4f `=scalar(fittest_value)'
		}
		else if `=scalar(arms)'>1{
			di in green "Smallest maximum pairwise SMD" _col(31)"=" in yellow _col(33) %6.4f `=scalar(fittest_value)'
		}
		
		forvalues m=1/`iterate'{
			if `=scalar(fittest_value)'==I[`m',2]{
				scalar fittest_seed=`m'+`=scalar(seed)'-1
			}
		}
		
		**Display the best seed number**
		
		di ""
		if `=scalar(arms)'==1{
			di in green "Best seed number" _col(28)"=" in yellow _col(30) `=scalar(fittest_seed)'
		}
		else if `=scalar(arms)'>1{
			di in green "Best seed number" _col(31)"=" in yellow _col(33) `=scalar(fittest_seed)'
		}
			
		return matrix I I
	}
	
	
	else if `iterate'==0{
		
	**Simple Matching without iteration**
	**Keep the original data**
		
	**Pre-define tempfile for append options, finally be erased by system**
		if "`append'"!=""{
			qui save "`c(pwd)'\prematched.dta", replace
			if `touse'{
		display "{it:If condition} may not be applied the append option"
			}
		}
		
		**Actual matching**
		forvalues p=0/`=scalar(pattern)'{
			scalar min=`=scalar(n)'
			forvalues a=0/`=scalar(arms)'{
				qui count if `name'==s[`p',1] & `group'==`a' & `touse'
				scalar n_`a'=r(N)
				qui scalar min="`=scalar(min)'"+","+"`=scalar(n_`a')'"
			}
			scalar min_num=min(`=scalar(min)')
			forvalues a=0/`=scalar(arms)'{
				set seed `=scalar(seed)'
				qui sample `=scalar(min_num)' if `name'==s[`p',1] & `group'==`a' & `touse',count
			}
		}
			
		**Post matching diagnostic SMD/SMD Max**
		
		qui tab `group' if `touse'
		scalar arms=r(r)-1
		
		**Two treament arms**
		
		if "`smd'"!="" & `=scalar(arms)'==1 {
			qui stddiff `smd' if `touse',by(`group')
			
			**STDDIFF mean**
			
			scalar std_accum=0
			qui mat smd=r(stddiff)
				forvalues e=1/`=rowsof(smd)'{
					if smd[`e',1]==.{
							mat smd[`e',1]=0
					}
					scalar std_accum=`=scalar(std_accum)'+abs(smd[`e',1])
				}
				scalar std_represent=`=scalar(std_accum)'/`=rowsof(smd)'
			}
			**Show iteration log**
			if "`log'"!=""{
				di ""  
				di in green "Post match SMD Mean = " in yellow `=scalar(std_represent)'
			}
		
		**More than two treament arms**
		
		else if "`smd'"!="" & `=scalar(arms)'>1{
			capture drop `group'_*
			qui tab `group' if `touse',gen(`group'_)
			scalar std_max=0
			forvalues i=0/`=scalar(arms)'{
				forvalues j=1/`=scalar(arms)'{
					if `i'<`j'{
						qui stddiff `smd' if (`group'==`i' | `group'==`j') & `touse',by(`group')
						forvalues k=1/`=rowsof(r(stddiff))'{
							if r(stddiff)[`k',1]==.{
								r(stddiff)[`k',1]=0
							}
							scalar std_max=max(`=scalar(std_max)',abs(r(stddiff)[`k',1]))
						}
					}
				}
			}
			scalar std_represent=`=scalar(std_max)'
			**Show iteration log**
			if "`log'"!=""{
				di ""  
				di in green "Post match SMD Max = " in yellow `=scalar(std_represent)'
			}
		}
		if "`notable'"==""{
			tab `name' `group' if `touse'
		} 
	}
if "`smd'"!=""{
	return scalar smallest=`=scalar(std_represent)'
}
if "`append'"!=""{
	append using "`c(pwd)'\prematched.dta",generate(append)
	display "The original cohort was kept and appended next to the last observations of matched cohort"
	erase prematched.dta
	if `touse'{
		display "{it:If condition} may not be applied the append option"
	}
}
return scalar seed=`=scalar(seed)'
return scalar size=`size'
return local name `name'
return local group `group'
return local iterate `iterate'
end