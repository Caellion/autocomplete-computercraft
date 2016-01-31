fs = require 'fs'
path = require 'path'

module.exports =
    selector: '.source.computercraft'
    filterSuggestions: true

    getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
        @getPossibleCommands(@completions.commands, @getPrefix(editor, bufferPosition))

    # onDidInsertSuggestion: ({editor, suggestion}) ->
        
    loadCommands : ->
        @completions = {}
        fs.readFile path.resolve(__dirname, '..', 'api.json'), (error, content) =>
            @completions = JSON.parse(content) unless error?
            return

    getPossibleCommands: (allCommands, prefix) ->
        
        console.log allCommands
        console.log prefix
        
        suggestions = []
        if prefix.indexOf(".") > 0
            console.log "recursive"
            lastSection = prefix.split(".")
            #Remove first element   
            firstElement = lastSection.shift()
            suggestions = @getPossibleCommands(allCommands[firstElement], lastSection.join('.'))
        else
            for command, subcommands of allCommands when not prefix or firstCharsEqual(command, prefix)
                suggestions.push(@buildSuggestion(command))
        console.log suggestions
        suggestions
        
    buildSuggestion: (command) ->
        text: command
        type: 'function'
        
    getPrefix: (editor, bufferPosition) ->
        # Whatever your prefix regex might be
        regex = /([\w]+\.?)+/
        line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
        line.match(regex)?[0] or ''
        
firstCharsEqual = (str1, str2) ->
    str1[0].toLowerCase() is str2[0].toLowerCase()
