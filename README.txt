= Chit

http://github.com/nowa/chit
http://github.com/robin/chit

== DESCRIPTION:

Chit is a command line cheat sheet utility based on git.

== FEATURES:

Chit was inspired by 'cheat' (http://cheat.errtheblog.com/) by Chris Wanstrath. You can use chit to access and manage cheat sheets easily. 

There are several differences between ‘cheat’ and ‘chit’. By using chit, besides the wonderful features of ‘cheat’, you get:

1. Git powered cheat sheet repository. You can specify where you get the sheets and where to share them.
2. Your own private cheat sheets. Everybody has some project related or smoe cheat sheets which are not mean to public. You can also put them into chit
3. Directory support. You can group cheat sheets by directory now.
4. One less letter to type.

== SYNOPSIS:

To initialize chit repositories

$ chit --init

This will be run automatically when you run chit for the first time. 

To get a cheat sheet:

$ chit [cheatsheet]

To edit a cheat sheet, use the --edit/-e switch.

$ cheat [cheatsheet] --edit

To add a cheat sheet, use the --add/-a switch.

$ cheat [cheatsheet] --add

During editing a cheat sheet, empty the content will get the cheat sheet removed.

A prefix '@' indicates the cheat sheet is in special mode. In this mode cheat sheet is kept in another repositories.

To specified repository cheat sheet in:

$ chit @[repos_name] cheatsheet

The prefix '@' works the same for both --edit/-e and --add/-a.

The cheat sheet can be in a path. For example:

$ chit mysql/select

will get the cheat sheet 'select' under mysql.

To show all the cheat sheets:

$ chit [all|sheets]

To show all the private cheat sheets:

$ chit @[repos_name] all|sheets

To find cheat sheets begin with 'name', use the --find/-f switch

$ chit name --find

To search cheat sheets content with 'text', use the --search/-s switch

$ chit text --search

To move or rename a sheet, use '--mv/-m' switch

$ chit zsh_if zsh/if -m

== INSTALL:

sudo gem install robin-chit -s http://gems.github.com

chit --init

== CONFIGURATION:

Before run 'chit', you may want to config ~/.chitrc which is a YAML file.

* root: local path to store the cheat sheet. By default, it is ~/.chit
* add_if_not_exist: when set as 'true', if no sheets found, a new one will be created and waiting for editing. Leave it blank and quit the editor if you don't want to add a new one.
* respo: you can set not only one repository
* main: 
* clone-from: where to get the public cheat sheets. You can use git://github.com/robin/chitsheet.git, which is a snap shoot of http://cheat.errtheblog.com/.
* private:
* clone-from: where to get the private cheat sheets. If not specified, a new git repository will be init for private cheat sheets.

== REQUIREMENTS:

* rubygems
* git

== LICENSE:

This software is shared by MIT License

Copyright (c) 2008 Robin Lu

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

== BY:

Robin Lu, nowa

http://www.robinlu.com
http://www.nowazhu.com

iamawalrus[at]gmail[dot]com
nowazhu[at]gmail[dot]com