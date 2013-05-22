org-hlc
=======

## License and Authorship

Copyright (C) 2013 Thorsten Jolitz

Author: Thorsten Jolitz <tjolitz at gmail dot com>

Keywords: org-mode, outline, visibility, overlays

This file is (NOT YET) part of GNU Emacs.

GNU Emacs is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GNU Emacs is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

## Commentary

org-hlc.el implements **hidden-lines-cookies** for Org-mode

*hidden-lines-cookies (hlc)* are small cookies at the end of each folded
(and visible) headline in an Org-mode buffer that show the number of hidden
lines before the next visible headline.

hidden-lines-cookies can be handled with three user commands:
`org-hlc-show-hidden-lines-cookies`, `org-hlc-hide-hidden-lines-cookies`,
and the convenience command `org-hlc-toggle-hidden-lines-cookies` that
toggles between the two other commands conditional on the last one
executed.

The appearance of the cookies can be customized by changing the values of
four customizable variables: `org-hlc-hidden-lines-cookie-left-delimiter`
(with default value "["), `org-hlc-hidden-lines-cookie-right-delimiter`
(with default value "]"), `org-hlc-hidden-lines-cookie-left-signal-char`
(with default value "#") and
`org-hlc-hidden-lines-cookie-right-signal-char` (with default value "").

Thus an exemplary folded headline with 165 hidden lines before the next
visible headline might look like this when hidden-lines-cookies are shown:

,-----------------
| *** Headline [#165]
`-----------------
