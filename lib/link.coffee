{_} = require 'atom'

module.exports =
  activate: ->
    atom.workspaceView.command 'link:open', '.editor', =>
      editor = atom.workspaceView.getActivePaneItem()
      return unless editor?

      token = editor.tokenForBufferPosition(editor.getCursorBufferPosition())
      return unless token?

      unless @selector?
        {ScopeSelector} = require 'first-mate'
        @selector = new ScopeSelector('markup.underline.link')

      if @selector.matches(token.scopes)
        url = token.value
        if editor.getGrammar().scopeName is 'source.gfm'
          url = @linkUrlForName(editor.getBuffer(), url)

        require('shell').openExternal(url)

  linkUrlForName: (buffer, linkName) ->
    url = linkName
    regex = new RegExp("^\\s*\\[#{_.escapeRegExp(linkName)}\\]\\s*:\\s*(.+)$", 'g')
    buffer.backwardsScanInRange regex, buffer.getRange(), ({match, stop}) ->
      url = match[1]
      stop()
    url
