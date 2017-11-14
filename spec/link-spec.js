const {shell} = require('electron')

const {it, fit, ffit, afterEach, beforeEach} = require('./async-spec-helpers') // eslint-disable-line no-unused-vars

describe('link package', () => {
  beforeEach(async () => {
    await atom.packages.activatePackage('language-gfm')
    await atom.packages.activatePackage('language-javascript')
    await atom.packages.activatePackage('language-hyperlink')

    const activationPromise = atom.packages.activatePackage('link')
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'link:open')
    await activationPromise
  })

  describe('when the cursor is on a link', () => {
    it("opens the link using the 'open' command", async () => {
      await atom.workspace.open('sample.js')

      const editor = atom.workspace.getActiveTextEditor()
      editor.setText('// "http://github.com"')

      spyOn(shell, 'openExternal')
      atom.commands.dispatch(atom.views.getView(editor), 'link:open')
      expect(shell.openExternal).not.toHaveBeenCalled()

      editor.setCursorBufferPosition([0, 4])
      atom.commands.dispatch(atom.views.getView(editor), 'link:open')

      expect(shell.openExternal).toHaveBeenCalled()
      expect(shell.openExternal.argsForCall[0][0]).toBe('http://github.com')

      shell.openExternal.reset()
      editor.setCursorBufferPosition([0, 8])
      atom.commands.dispatch(atom.views.getView(editor), 'link:open')

      expect(shell.openExternal).toHaveBeenCalled()
      expect(shell.openExternal.argsForCall[0][0]).toBe('http://github.com')

      shell.openExternal.reset()
      editor.setCursorBufferPosition([0, 21])
      atom.commands.dispatch(atom.views.getView(editor), 'link:open')

      expect(shell.openExternal).toHaveBeenCalled()
      expect(shell.openExternal.argsForCall[0][0]).toBe('http://github.com')
    })

    describe('when the cursor is on a [name][url-name] style markdown link', () =>
      it('opens the named url', async () => {
        await atom.workspace.open('README.md')

        const editor = atom.workspace.getActiveTextEditor()
        editor.setText(`\
you should [click][here]
you should not [click][her]

[here]: http://github.com\
`
        )

        spyOn(shell, 'openExternal')
        editor.setCursorBufferPosition([0, 0])
        atom.commands.dispatch(atom.views.getView(editor), 'link:open')
        expect(shell.openExternal).not.toHaveBeenCalled()

        editor.setCursorBufferPosition([0, 20])
        atom.commands.dispatch(atom.views.getView(editor), 'link:open')

        expect(shell.openExternal).toHaveBeenCalled()
        expect(shell.openExternal.argsForCall[0][0]).toBe('http://github.com')

        shell.openExternal.reset()
        editor.setCursorBufferPosition([1, 24])
        atom.commands.dispatch(atom.views.getView(editor), 'link:open')

        expect(shell.openExternal).not.toHaveBeenCalled()
      })
    )

    it('does not open non http/https links', async () => {
      await atom.workspace.open('sample.js')

      const editor = atom.workspace.getActiveTextEditor()
      editor.setText('// ftp://github.com\n')

      spyOn(shell, 'openExternal')
      atom.commands.dispatch(atom.views.getView(editor), 'link:open')
      expect(shell.openExternal).not.toHaveBeenCalled()

      editor.setCursorBufferPosition([0, 5])
      atom.commands.dispatch(atom.views.getView(editor), 'link:open')

      expect(shell.openExternal).not.toHaveBeenCalled()
    })
  })
})
