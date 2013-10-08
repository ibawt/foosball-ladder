class FoosballLadder.Team extends Batman.Model
  @resourceName: 'teams'
  @storageKey: 'teams'

  @persist Batman.RailsStorage

  # Use @encode to tell batman.js which properties Rails will send back with its JSON.
  # @encode 'name'
  @encodeTimestamps()

