txt2html
========

A simple way to generate HTML documents from text files a'la README.

For now i only have the wrapper script called expiditaa.sh in this project.
This tool tries to find ASCII-art diagrams in your text-file and export parts
of it to PNG-files using ditaa.

Try it out and chack how it feels.

Requirements
------------

You need to have the **wonderful** tool caooed "ditaa" by Stathis Siderisa
vailable at: http://ditaa.sourceforge.net

Another required tool is the "rst2html" tool in python3-docutils available at:
http://docutils.sourceforge.net/docs/user/tools.html#rst2html-py

These tools are essentially the engine behind this little wrapper script, so
the authors of those basically get all the credit, from my point of view.

Plans
-----

I plan to make a wrapper script called txt2html that does exactly this and
also keep the actual ASCII-art diagrams in a pre-formated HTNL tag but replace
it with a bitmap image using CSS. :)

Let's see how this works out.

