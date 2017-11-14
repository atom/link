# Link package
[![OS X Build Status](https://travis-ci.org/atom/link.png?branch=master)](https://travis-ci.org/atom/link) [![Windows Build Status](https://ci.appveyor.com/api/projects/status/1d3cb8ktd48k9vnl/branch/master?svg=true)](https://ci.appveyor.com/project/Atom/link/branch/master) [![Dependency Status](https://david-dm.org/atom/link.svg)](https://david-dm.org/atom/link)

Opens http(s) links under the cursor using <kbd>ctrl-shift-o</kbd>.

---

Linux or Windows users can add the following line to their `keymap.cson` under the `'atom-workspace'` key to open links with <kbd>alt-o</kbd>:

```
  'alt-o': 'link:open'
```

If you do not have an `'atom-workspace'` key in `keymap.cson`, add the following section:

```
'atom-workspace':
  'alt-o': 'link:open'
```
