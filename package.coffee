pack = Packages.register
  name: 'macro'
  description: 'implements the ability to record to named macros'

macros = {}
currentMacro = null

Chain.preprocess {
  scope: 'global'
  name: 'save-chain-to-macro-chain'
  }, (chain) ->
    if currentMacro?
      safeChain = _.reduce chain, (newChain, link, index) ->
        if link.command != 'macro:record-macro'
          newChain.push link
        newChain
      , []
      macroChain = macros[currentMacro]
      macroChain.push safeChain
    chain

pack.commands
  'record-macro':
    spoken: 'maghreb'
    description: 'begins/stops recording a macro'
    grammarType: 'oneArgument'
    enabled: true
    action: (input) ->
      if currentMacro?
        notify "Saved '#{currentMacro}'"
        currentMacro = null
      else
        notify "Recording '#{input}'"
        macros[input] = []
        currentMacro = input
  'execute-macro':
    spoken: 'maglite'
    description: 'executes a macro'
    grammarType: 'oneArgument'
    enabled: true
    action: (input) ->
      return if currentMacro?
      return unless macros[input]?
      notify "Executing '#{input}'"
      macroChain = _.flatten macros[input]
      macroChain = _.cloneDeep macroChain
      new Chain().execute macroChain, false
