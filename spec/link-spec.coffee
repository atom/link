{RootView} = require 'atom'
shell = require 'shell'

describe "link package", ->
  [editor] = []

  beforeEach ->
    atom.packages.activatePackage('language-javascript', sync: true)
    atom.packages.activatePackage('language-hyperlink', sync: true)
    atom.rootView = new RootView
    atom.rootView.openSync('sample.js')
    atom.packages.activatePackage('link')
    atom.rootView.attachToDom()
    editor = atom.rootView.getActiveView()
    editor.insertText("// http://github.com\n")

  describe "when the cursor is on a link", ->
    it "opens the link using the 'open' command", ->
      spyOn(shell, 'openExternal')
      editor.trigger('link:open')
      expect(shell.openExternal).not.toHaveBeenCalled()

      editor.setCursorBufferPosition([0,5])
      editor.trigger('link:open')

      expect(shell.openExternal).toHaveBeenCalled()
      expect(shell.openExternal.argsForCall[0][0]).toBe "http://github.com"
