{smcl}
{* 08oct2023}
{title: Title}

{p 4 8}{cmd:adoactive} - Stata module to identify and return a list of user-written STATA cmds called in a given Dofile.

{p 8 17 2}
{cmd:adoactive}
{it:{help filename}}
{cmd:[,} {opt path(path_to_filename)}{cmd:]}

{title: Description}

{p 4 8}{cmd:adoactive} returns a list of user-written STATA commands (ados) called in the specified Dofile {it:{help filename}}.
	It also returns the location of the ado files. The list of ados in saved in {it: r(adolist)}.


{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt path()}} Specify location of {it:{help filename}}. If omitted, current directory is assumed.


{title:Credits}

{p 4}This module is inspired by and partially relies on the modules {help callsado} (by Daniel Klein) and {help getcmds}.{p_end}

{title:Author}

{p 4}Jean-Victor Alipour{p_end}
{p 4}LMU Munich & ifo Institute{p_end}
{p 4}{browse "https://sites.google.com/view/jv-alipour/"}{p_end}

