# Branch Protocol #

Please fork from the `dev` branch for submitting code changes. 

The `dev` branch is regularly merged into the `master` branch.

The `master` is the current stable development version. That is, it regularly changes, but if you clone it, it should work OK.

Stable releases are published and tagged - available from the `release` tab.


# Code Style #

I use TAB indents. I appreciate this is swimming against the tide, but hear me out.

With TAB indents every body can look at the same code, but view it with their own preferred indentation. You just set the tab-stops on your editor / viewer
to whatever you like. I use a tabstop of 4, but I know a lot of people prefer 2 or 3.

In `vi`, you do this with `set tabstop=4` & `set sw=4`. Put these in you `.exrc`. Now you can indent the next line by pressing tab, and
when you use `<` or `>` to re-indent, it will re-indent by 4 columns each time.

You can view the code using `less`, by adding `-X 4`, e.g. `alias less="less -X4"`

Using TAB indents also significantly reduces the file size, although, yes, minify will eliminate this issue anyway.
