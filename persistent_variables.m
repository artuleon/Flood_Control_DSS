function persistent_variables()
    mlock
    %persistent AllocatedInteger
    persistent path_general2   
    
    home_dir = pwd; %This returns the working directory.
    path_general2 = home_dir
    
end