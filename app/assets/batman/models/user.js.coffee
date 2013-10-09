class FoosballLadder.User extends Batman.Model
  @resourceName: 'users'
  @storageKey: 'users'

  @persist Batman.RailsStorage

  # Use @encode to tell batman.js which properties Rails will send back with its JSON.
  @encode 'email'

  @belongsTo 'team', foreignKey: 'team_id'
      
  @encodeTimestamps()

