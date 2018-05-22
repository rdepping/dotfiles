# .cshrc: executed by C shells on startup
# 
# This is intended to be a means of launching always 
# Bash even if Csh/Tcsh is configured as the login 
# shell (think: old-fashioned IT departments).

# If this is login or some command is to be executed
# then change to a sane shell
if ($?loginsh || $?command) then # switch to bash
    setenv SHELL /bin/bash
    if ($?loginsh) then 
        if ($?command) then 
            exec /bin/bash --login -c "$command"
        endif
        exec /bin/bash --login 
    endif
    # not a login shell, so there must be command
    exec /bin/bash -c "$command"
endif
# go ahead, use csh
