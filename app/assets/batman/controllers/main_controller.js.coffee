class FoosballLadder.MainController extends FoosballLadder.ApplicationController
  routingKey: 'main'

  index: (params) ->
    FoosballLadder.Team.load (err,teams) =>
      @set 'teams', teams

  @accessor 'teamsToJoin', ->
    @get('teams').filter( (t) -> t.get('users').count() < 2 )

