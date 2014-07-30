
homebrew-dev
============
Misc [Homebrew][1] formulae.


How do I install these formulae?
--------------------------------
Just `brew tap larrybradley/dev` or `brew tap
larrybradley/homebrew-dev` and then `brew install <formula>`.

If the formula conflicts with one another tap, you can `brew install
larrybradley/dev/<formula>`.

You can also install via URL:

`brew install https://raw.github.com/larrybradley/homebrew-dev/master/<formula>.rb`


`opencv` Install Notes
----------------------
The `--HEAD` version of `opencv` needs to be installed with
`--env=std`:

`brew install --HEAD --env=std larrybradley/dev/opencv`


Docs
----
`brew help`, `man brew`, or the Homebrew [wiki][1].


[1]: http://wiki.github.com/Homebrew/homebrew
