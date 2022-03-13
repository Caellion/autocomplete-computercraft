fs = require 'fs'
path = require 'path'

module.exports =
    selector: '.source.computercraft'
    filterSuggestions: true

    getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
        @getPossibleClass(@completions.childClasses, @getPrefix(editor, bufferPosition))

    onDidInsertSuggestion: ({editor, suggestion}) ->
        if suggestion.type is 'class'
            editor.insertText('.')
            setTimeout(@triggerAutocomplete.bind(this, editor), 1)


    triggerAutocomplete: (editor) ->
        atom.commands.dispatch(atom.views.getView(editor), 'autocomplete-plus:activate', {activatedManually: false})

    loadCommands : ->
        @completions = {}
        fs.readFile path.resolve(__dirname, '..', 'api.json'), (error, content) =>
            @completions = JSON.parse(content) unless error?
            return

    getPossibleClass: (allCommands, prefix) ->

        #console.log allCommands
        #console.log prefix

        suggestions = []
        if prefix.indexOf(".") > 0
            splitPrefix = prefix.split(".")
            #Remove first element
            firstElement = splitPrefix.shift()
            for command in allCommands
                if command.className is firstElement
                    if command.childClasses.length is 0
                        # methods
                        suggestions = @getPossibleMethod(command.methods, splitPrefix.join('.'))
                    else
                        # classes
                        suggestions = @getPossibleClass(command.childClasses, splitPrefix.join('.'))
                    break
        else
            for command in allCommands
                if prefix.length == 0 or firstCharsEqual(command.className, prefix)
                    suggestions.push(@buildClass(command.className))

        #console.log suggestions
        suggestions

    getPossibleMethod: (methods, prefix) ->
        suggestions = []

        #TODO: Remove dirty hack
        if not prefix.endsWith('(')
            for method in methods
                if prefix.length is 0 or firstCharsEqual(method.method, prefix)
                    suggestions.push(@buildMethod(method.method, method.description, method.parameter, method.returnValue))
        suggestions

    buildClass: (childClass) ->
        text: childClass
        type: 'class'

    buildMethod: (command, description, parameter, returnValue) ->
        displayText: command
        text: command + parameter
        leftLabel: returnValue
        description: description
        type: 'method'

    getPrefix: (editor, bufferPosition) ->
        # Whatever your prefix regex might be
        regex = /([\w]\.?)+\(?$/
        line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
        line.match(regex)?[0] or ''

firstCharsEqual = (str1, str2) ->
    str1[0].toLowerCase() is str2[0].toLowerCase()
