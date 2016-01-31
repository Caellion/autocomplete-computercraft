describe "ComputerCraft autocompletions", ->
    [editor, provider] = []

    getCompletions = ->
        cursor = editor.getLastCursor()
        start = cursor.getBeginningOfCurrentWordBufferPosition()
        end = cursor.getBufferPosition()
        prefix = editor.getTextInRange([start, end])
        request =
            editor: editor
            bufferPosition: end
            scopeDescriptor: cursor.getScopeDescriptor()
            prefix: prefix
        provider.getSuggestions(request)

    beforeEach ->
        waitsForPromise -> atom.packages.activatePackage('autocomplete-computercraft')
        waitsForPromise -> atom.packages.activatePackage('language-computercraft')

        runs ->
            provider = atom.packages.getActivePackage('autocomplete-computercraft').mainModule.getProvider()

        waitsFor -> Object.keys(provider.completions).length > 0
        waitsForPromise -> atom.workspace.open('test')
        runs ->
            editor = atom.workspace.getActiveTextEditor()
            editor.setGrammar(atom.grammars.grammarForScopeName('source.computercraft'))
    
    it "return three or more suggestions on empty prefix", ->
        editor.setText('')
        expect(getCompletions().length).toBeGreaterThan 2
        
    it "return 'os' on first level", ->
        editor.setText('os')
        expect(getCompletions()[0].text).toBe 'os'
        
        editor.setText('o')
        expect(getCompletions()[0].text).toBe 'os'
        
    it "return suggestions on second level", ->
        editor.setText('os.')
        expect(getCompletions().length).toBeGreaterThan 1
        
    it "return version on second level", ->
        editor.setText('os.version')
        expect(getCompletions()[0].text).toBe 'version'
