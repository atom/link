{WorkspaceView} = require 'atom'
shell = require 'shell'

describe "link package", ->
  [editor, editorView] = []

  beforeEach ->
    atom.packages.activatePackage('language-javascript', sync: true)
    atom.packages.activatePackage('language-hyperlink', sync: true)
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.openSync('sample.js')
    atom.packages.activatePackage('link')
    atom.workspaceView.attachToDom()
    editorView = atom.workspaceView.getActiveView()
    {editor} = editorView
    editor.insertText("// http://github.com\n")

  describe "when the cursor is on a link", ->
    it "opens the link using the 'open' command", ->
      spyOn(shell, 'openExternal')
      editorView.trigger('link:open')
      expect(shell.openExternal).not.toHaveBeenCalled()

      editor.setCursorBufferPosition([0,5])
      editorView.trigger('link:open')

      expect(shell.openExternal).toHaveBeenCalled()
      expect(shell.openExternal.argsForCall[0][0]).toBe "http://github.com"
