set designer "ESE-507 Student";
set company "Stony Brook University";  

set search_path {. ./usrlibs ./lib_code /usr/local/synopsys/syn/libraries/syn /home/home4/pmilder/ese507/synthesis/lib}
set target_library {NangateOpenCellLibrary_typical.db} ;# other choices such as _fast, _slow ...

set synthetic_library {dw_foundation.sldb}
set link_library [concat $target_library $synthetic_library]

