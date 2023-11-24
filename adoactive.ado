*! version 1.0.0, Jean-Victor Alipour, 10oct2023

/* module to identify commands that are not built-in stata cmds in given Dofile */
cap program drop adoactive
program adoactive, rclass
	version 17

// Define syntax and options for the program
	syntax anything(id = "filename" name = filename) [, Path(passthru)]
	
	// create file builtin_cmds.txt 
	getbuilt
	
	// Check if file successfully created
	qui findfile builtin_cmds.txt
	loc builtin `r(fn)'	
	
	// Check if the file exists and strip its name
	qui findfile `filename' ,`path'
	loc filename `r(fn)'
	
	// read builtin commands list
	tempname fb
	file open `fb' using `builtin' , read
	file read `fb' line

	local cmds=""
	while r(eof)==0 {
        local cmds = "`cmds' `line'" // Each line is a separate command
		file read `fb' line
    }

	file close `fb'
	
	// read dofile
	* create tempfile
	tempfile tmp tmp1
	filef `"`filename'"' `"`tmp1'"' ,f(\t) t(" ")
	filef `"`tmp1'"' `"`tmp'"' ,f(\LQ) t("{c 96}")
	qui filef `"`tmp'"' `"`tmp1'"' ,f(\RQ) t("{c 39}") r
	qui filef `"`tmp1'"' `"`tmp'"' ,f(\$) t("{c 36}") r

	tempname fh
	file open `fh' using `tmp' , read text
	file read `fh' line

	local adolist= ""
	local skipline=0
	
	// Loop through each line in the file	
 while r(eof)==0 {
		
	// if skipline =1 , skip 
	if `skipline'==1 {
		if ustrregexm(`"`line'"',"///$")==0 { 	// only switch if this is the end of a linebreaker
			local skipline=0
		}	
		file read `fh' line
		continue
		
	}
	
	// if line ends in /// => skip the following line
	if ustrregexm(`"`line'"',"///$")==1 {
		local skipline=1
	}
		
	// if line starts comment "//" or "*" => skip
	if ustrregexm(`"`line'"',"^[\s]*(\*|\/\/)?$")==1 {
		file read `fh' line
		continue
	}
	// clean line of text enclosed between /* ... */ (in the same line)
	if ustrregexm(`"`line'"',"/\*")==1 & ustrregexm(`"`line'"',"\*/")==1 {
		local line = regexr(`"`line'"', "/\*[^*]*\*+([^/*][^*]*\*+)*/", "")
	}
	
	// skip multiline comments enclosed by /* ... */
	if ustrregexm(`"`line'"',"^[\s]*/\*")==1 { // checks if line starts with /*
		file read `fh' line
		while ustrregexm(`"`line'"',"\*/")==0 & r(eof)==0 {  // next line until */ met
			file read `fh' line
		}	
		file read `fh' line
		continue
	}
	
	// save first word in local match
	if ustrregexm(`"`line'"',"^\s*([a-zA-Z0-9_]+)")==1 {
		 local match = ustrregexs(1)
		 // check if word included in builtin-list
		 if ustrregexm("`cmds'","\b`match'\b")==1 {
			file read `fh' line
			continue
		 }
		 else 
		  {
		  	if ustrregexm("`adolist'","\b`match'\b")==0 { // check if alread in list, and add to adolist
				local adolist = "`adolist' `match'"
			}	
		  }
	}	 
	file read `fh' line
 }	
 file close `fh'
	
	// Return results 
	 di as err "List of ados + location:"
	 foreach x in `adolist' {
		di as error "Cmd: `x'"
		cap noi which "`x'"
	 }
	 return local adolist `adolist'
	 
	 // erase builtin_cmds.txt 
	qui erase  builtin_cmds.txt 

end



cap program drop getbuilt 
program define getbuilt, rclass
	
	local using builtin_cmds.txt
	local types nonadoonly
	local pwd : pwd

	tempname ww
	qui file open `ww' using `using', write text replace 

	preserve
	drop _all

capture noisily quietly {

	cd `"`c(sysdir_base)'"'
	GetFiles `ww' `types'
	if c(stata_version) < 13 {
		cd `"`c(sysdir_updates)'"'
		GetFiles `ww' `types'
	}
	cd `"`c(sysdir_plus)'"'
	GetFiles  `ww' `types'
	ReadAlias `ww' `types'
	

}

	local rc = c(rc)
	capture file close `ww'

	qui cd `"`pwd'"'
	if (`rc') exit `rc'

	qui infile str80 cmds using `using', clear
	sort cmds
	by cmds: gen copy = _n
	qui drop if copy > 1
	qui outfile cmds using `using', replace noquote
end


cap program drop ReadAlias
program ReadAlias
	args ww types
	if c(stata_version) < 9 {
		local flist help_alias.maint
	}
	else {
		local llist _ a b c d e f g h i j k l m n o p q r s	///
			t u v w x y z
		foreach l of local llist {
			local flist `flist' `l'help_alias.maint
		}
	}
	foreach file of local flist {
		qui findfile `file'
		qui infile str80 cmd str80 hlp using `"`r(fn)'"', clear
		forval i = 1/`=c(N)' {
			local cmd `=cmd[`i']'
			capture unabcmd `cmd'
			if !c(rc) {
				if "`r(cmd)'" != "`cmd'" {
					local abcmd file write `ww' "`cmd'" _n
				}
				else	local abcmd
				local cmd `r(cmd)'
				cap findfile `cmd'.ado
				if c(rc) {
					`abcmd'
					file write `ww' "`cmd'" _n
				}
			}
		}
	}
end

cap program drop GetFiles
program GetFiles
	args ww types
	local dlist : dir "." dirs "*"
	foreach dir of local dlist {
		`types' `ww' `dir'
	}
end

cap program drop nonadoonly
program nonadoonly
	args ww dir
	TypeLoop `ww' `dir' hlp
	if c(stata_version) >= 10 {
		TypeLoop `ww' `dir' sthlp
	}
end

cap program drop TypeLoop
program TypeLoop
	args ww dir type ado
	local list : dir "`dir'" files "*.`type'"
	foreach file of local list {
		local base : subinstr local file ".`type'" ""
		if "`type'" != "ado" {
			capture findfile `base'.ado
			if c(rc) {
				capture which `base'
				if c(rc) local base
			}
			else if "`ado'" == "" {
				local base
			}
		}
		if "`base'" != "" {
			file write `ww' "`base'" _n
		}
	}
end