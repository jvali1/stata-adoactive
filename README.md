# adoactive.ado
`adoactive` is a STATA module designed to identify and list user-written STATA commands (ados) invoked in a specified Dofile.
This can be useful for replication purposes as many journals require copies of user-written programs at the version used.
`adoactive` identifies them and specifies their version and location.

## Example
The syntax is simple, type:
```stata
adoactive mydofile.do, path(file_path)
```

## Installation
To install from Github, type:

```stata
net install adoactive, from("https://raw.githubusercontent.com/jvali1/stata-adoactive/master/") replace
```
## Author
For questions and suggestions, please contact:  
Jean-Victor Alipour  
LMU Munich & ifo Institute  
alipour@ifo.de
https://sites.google.com/view/jv-alipour/

## Credits
This module is inspired by and partially relies on the modules `callsado` (by Daniel Klein) and `getcmds`.