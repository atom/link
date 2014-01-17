module.exports =
  activate: ->
    atom.workspaceView.command 'link:open', '.editor', ->
      editor = atom.workspaceView.getActivePaneItem()
      return unless editor?

      token = editor.tokenForBufferPosition(editor.getCursorBufferPosition())
      return unless token?

      unless @selector?
        {ScopeSelector} = require 'first-mate'
        @selector = new ScopeSelector('markup.underline.link')

      if @selector.matches(token.scopes)
        require('shell').openExternal token.value
