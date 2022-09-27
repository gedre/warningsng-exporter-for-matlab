% Some dummy code to demonstrate mlint warnings
a = []; for i = 1:10, a(end+1) = 1; end % Note: this line causes a "variable appears to change size ..." warning on purpose.
