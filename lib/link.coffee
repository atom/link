url = require 'url'
# TODO: Remove the catch once Atom 1.7.0 is released
try {shell} = require 'electron' catch then shell = require 'shell'
_ = require 'underscore-plus'

selector = null

module.exports =
  activate: ->
    atom.commands.add('atom-workspace', 'link:open', openLink)
    atom.views.getView(atom.workspace).on 'click', (event) ->
      openLink() if event.metaKey

openLink = ->
  editor = atom.workspace.getActiveTextEditor()
  return unless editor?

  link = linkUnderCursor(editor)
  return unless link?

  if editor.getGrammar().scopeName is 'source.gfm'
    link = linkForName(editor.getBuffer(), link)

  {protocol} = url.parse(link)
  if protocol is 'http:' or protocol is 'https:'
    shell.openExternal(link)

# Get the link under the cursor in the editor
#
# Returns a {String} link or undefined if no link found.
linkUnderCursor = (editor) ->
  cursorPosition = editor.getCursorBufferPosition()
  link = linkAtPosition(editor, cursorPosition)
  return link if link?

  # Look for a link to the left of the cursor
  if cursorPosition.column > 0
    linkAtPosition(editor, cursorPosition.translate([0, -1]))

# Get the link at the buffer position in the editor.
#
# Returns a {String} link or undefined if no link found.
linkAtPosition = (editor, bufferPosition) ->
  unless selector?
    {ScopeSelector} = require 'first-mate'
    selector = new ScopeSelector('markup.underline.link')

  if token = editor.tokenForBufferPosition(bufferPosition)
    token.value if token.value and selector.matches(token.scopes)

# Get the link for the given name.
#
# This is for Markdown links of the style:
#
# ```
# [label][name]
#
# [name]: https://github.com
# ```
#
# Returns a {String} link
linkForName = (buffer, linkName) ->
  link = linkName
  regex = new RegExp("^\\s*\\[#{_.escapeRegExp(linkName)}\\]\\s*:\\s*(.+)$", 'g')
  buffer.backwardsScanInRange regex, buffer.getRange(), ({match, stop}) ->
    link = match[1]
    stop()
  link
