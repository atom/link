{WorkspaceView} = require 'atom'
shell = require 'shell'

describe "link package", ->
  beforeEach ->
    atom.packages.activatePackage('language-gfm', sync: true)
    atom.packages.activatePackage('language-javascript', sync: true)
    atom.packages.activatePackage('language-hyperlink', sync: true)

    atom.workspaceView = new WorkspaceView
    atom.packages.activatePackage('link')

  describe "when the cursor is on a link", ->
    it "opens the link using the 'open' command", ->
      atom.workspaceView.openSync('sample.js')
      editorView = atom.workspaceView.getActiveView()
      {editor} = editorView
      editor.setText("// http://github.com\n")

      spyOn(shell, 'openExternal')
      editorView.trigger('link:open')
      expect(shell.openExternal).not.toHaveBeenCalled()

      editor.setCursorBufferPosition([0,5])
      editorView.trigger('link:open')

      expect(shell.openExternal).toHaveBeenCalled()
      expect(shell.openExternal.argsForCall[0][0]).toBe 'http://github.com'

    describe "when the cursor is on a [name][url-name] style markdown link", ->
      it "opens the named url", ->
        atom.workspaceView.openSync('README.md')
        editorView = atom.workspaceView.getActiveView()
        {editor} = editorView
        editor.setText """
          you should [click][here]

          [here]: http://github.com
        """
        spyOn(shell, 'openExternal')
        editorView.trigger('link:open')
        expect(shell.openExternal).not.toHaveBeenCalled()

        editor.setCursorBufferPosition([0,20])
        editorView.trigger('link:open')

        expect(shell.openExternal).toHaveBeenCalled()
        expect(shell.openExternal.argsForCall[0][0]).toBe 'http://github.com'
