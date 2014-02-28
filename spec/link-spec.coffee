{WorkspaceView} = require 'atom'
shell = require 'shell'

describe "link package", ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-gfm')

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.packages.activatePackage('language-hyperlink')

    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    waitsForPromise ->
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
          you should not [click][her]

          [here]: http://github.com
        """

        spyOn(shell, 'openExternal')
        editor.setCursorBufferPosition([0,0])
        editorView.trigger('link:open')
        expect(shell.openExternal).not.toHaveBeenCalled()

        editor.setCursorBufferPosition([0,20])
        editorView.trigger('link:open')

        expect(shell.openExternal).toHaveBeenCalled()
        expect(shell.openExternal.argsForCall[0][0]).toBe 'http://github.com'

        shell.openExternal.reset()
        editor.setCursorBufferPosition([1,24])
        editorView.trigger('link:open')

        expect(shell.openExternal).not.toHaveBeenCalled()

    it "does not open on http/https links", ->
      atom.workspaceView.openSync('sample.js')
      editorView = atom.workspaceView.getActiveView()
      {editor} = editorView
      editor.setText("// ftp://github.com\n")

      spyOn(shell, 'openExternal')
      editorView.trigger('link:open')
      expect(shell.openExternal).not.toHaveBeenCalled()

      editor.setCursorBufferPosition([0,5])
      editorView.trigger('link:open')

      expect(shell.openExternal).not.toHaveBeenCalled()
