url = require 'url'
shell = require 'shell'
_ = require 'underscore-plus'

module.exports =
  activate: ->
    atom.workspaceView.command 'link:open', =>
      editor = atom.workspace.getActiveEditor()
      return unless editor?

      token = editor.tokenForBufferPosition(editor.getCursorBufferPosition())
      return unless token?.value

      unless @selector?
        {ScopeSelector} = require 'first-mate'
        @selector = new ScopeSelector('markup.underline.link')

      if @selector.matches(token.scopes)
        link = token.value
        if editor.getGrammar().scopeName is 'source.gfm'
          link = linkForName(editor.getBuffer(), link)

        {protocol} = url.parse(link)
        if protocol is 'http:' or protocol is 'https:'
          shell.openExternal(link)

linkForName = (buffer, linkName) ->
  link = linkName
  regex = new RegExp("^\\s*\\[#{_.escapeRegExp(linkName)}\\]\\s*:\\s*(.+)$", 'g')
  buffer.backwardsScanInRange regex, buffer.getRange(), ({match, stop}) ->
    link = match[1]
    stop()
  link
