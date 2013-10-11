# Batman + Rails - Lets do some real work now

  So we've shown some basic CRUD in the previous tutorials.  Now it's time to actually do something with the
  data. We're going to add the ability to challenge other teams, and record that data.  We actually have some
  real logic to do here instead of the basic operations we have done up until now.
  
## Lets make a model again

  So let's step outside the text editor and think about how we would implement a foosball ladder.  We have
  users and teams, what's missing?  We need a way to model the actually game, in this case we'll call it
  `Match`.  A match will consist of the following fields:
  
    - team_one : the challenging team
	- team_two : the challenged team
	- team_one_score : the score in number of games 
	- team_two_score : the score in number of games
	- team_one_accepted_results: whether team_one indicates the results are good
	- team_two_accepted_results: whether team_two indicates teh results are good
	
  Anytime a team 'challenges' another team, they will make a `Match` object, with them being `team_one`.  The match results
  will not be valid until either team enters the scores and both teams accept the results.  Seems simple enough, so let's
  make some rails models.  We won't be adding score verification in this tutorial, but we will eventually!
  
  ```
  $ rails generate scaffold Match
  ```
  
  And as before this will make a migration and some boiler plate.  First we'll open the migration ( in `db/migrate/*create_match` ) and
  add the following fields:
  
  ```
  t.references :team_one, index: true
  t.references :team_two, index: true
  t.integer :team_one_score
  t.integer :team_two_score
  t.integer :team_one_accepted_results
  t.integer :team_two_accepted_results
  ```
  As you see this correspond with our design up above.  Now we'll add the associations into the ruby models.  In
  `match.rb` add:
  ```
  belongs_to :team_one, :class_name => 'Team'
  belongs_to :team_two, :class_name => 'Team'
  
  def completed?
    team_one_accepted_results && team_two_accepted_results
  end
  ```
  
  If you notice we added a helper method `completed?` which will tell our controller if the match has been completed.  We
  also had to add the `class_name` into the association.  This is because rails can't figure out the foreign key automatically,
  if the field was just `:team` it would have worked.
  
  Now in `team.rb` we'll add the reverse associations:
  
  ```
  has_many :team_ones, :class_name => 'Match', :foreign_key => 'team_one_id'
  has_many :team_twos, :class_name => 'Match', :foreign_key => 'team_two_id'
  ```
  
  We'll need to do a little bit more to make sure the routes are setup correctly.  The scaffold will stick the `resources` in the wrong
  place, so go into `routes.rb` and move the `:matches` resources down with the other resources.  If you remember last tutorial, if you 
  don't do this you'll get that error message when viewing the URL directly.
  
## Let's make some HTML and models for batman

  The ruby side is mostly done, lets add the batman models.  
  
  ```
  $ rails generate batman:model Match
  $ rails generate batman:controller matches
  ```
  
  We should now have some defaults for matches, lets add a navbar option for it in `batman.html.erb`.  It will be similar to the other
  resources that are already there.
  
  Now how will we create matches?  They should only be created when we challenge another team.  I think the best way to do this would be add
  some more information into the main page.  We have a default team listing that doesn't really make any sense in there right now.  Let's
  add a little part for your own team status, and a part where we can see all the teams and add the ability to change them.  Our main index
  is now turning into a 'dashboard', with a 'My Team' section where you can view your current challenges, and general 'Ladder' section which 
  will show us the list of teams ( with a rating eventually ).
  
## Lets do a partial!
  
  So we're going to start by adding a My Team dashboard.  We could embed this data into the `main/index.html` but it's seems like it should
  be in it's own file.  In batman we can refactor the 'My Team' dashboard into seperate HTML file called a `partial`.  A good pratice
  to indicate that this `partial` can be used anywhere would be to put it into a `shared` directory.  We follow the rails strategy of
  prepending an underscore to the partial to for readability but it's not enforced.
  
  Make a directory called `shared` in the `batman/html` directory, and make a file called `_team_dashboard.html`.  To get this bit of HTML
  into index.html we'll introduce another batman directive: `data-partial`.  This inserts the HTML in the argument into that page.  The completed 
  tag will look like this in `main/index.html`:
  
  ```
  <div class="span9" data-partial="shared/_team_dashboard"></div>
  ```
  
  In the file `_team_dashboard.html` we'll add some messages to indicate there's nothing there, and some crude placeholders for the
  dashboard interface.  
  
  The HTML looks like this:
  ```
  <div class="panel panel-default">
	<div class="panel-heading">
		<h4 class="panel-title" data-bind="currentUser.team.name | append ' Dashboard'"></h4>
	</div>
	<div class="panel-body">
		<div>Challenges:
			<div class="alert alert-warning" data-hideif="matchesToRecord">No matches to record!</div>
			<div showif="matchesToRecord" class="offset1" data-foreach-match="matchesToRecord">
				<div data-bind="match.id"></div><button type="button" class="btn btn-default" data-event-click="recordMatchResult"> Result...</button>
			</div>
		</div>
		<div>Matches to Confirm:
			<div class="alert alert-warning" data-hideif="matchesToConfirm">No matches to confirm!</div>
			<div class="offset1" data-foreach-match="matchesToConfirm">
				<div data-bind="match.id"></div>
				<div>Your Score: <div data-bind="match.myScore"></div></div>
				<div> Their Score: <div data-bind="match.theirScore"></div></div>
				<button type="button" class="btn btn-default" data-event-click="confirmResult">Confirm</button>
			</div>
		</div>
	</div>
   </div>
  ```
  
  There's a few new things in this HTML:
    - `append` in the dashboard title.  This is a feature of batman that lets us modify the values in a `data-bind` like attribute
	           to do a bunch of things.  In this case it's just appending the string ' Dashboard' to the team name.  There's a few
			   more list in the [Batman.Filter](http://batmanjs.org/docs/api/batman.view_filters.html) documentation.

	- `data-hideif` This will do as it seems, it will hide the attached node and everything below it.  In this case we're hiding
	                it if the value of `matchesToRecord` is false-ish.
					

   Now we haven't implemented the accessors or the button events, it's just a skeleton right now.  We have to make some way to
   challenge the other teams.
   
   We should also add some methods into the `main_controller` and the `matches_controller.rb` so we're reading to feed some data
   into the dashboard.
   
   In `main_controller.js.coffee`:
   
   ```
   index: (params) ->
    FoosballLadder.Team.load (err,teams) =>
      @set 'teams', teams

    matchParams = matches_for_team: FoosballLadder.currentUser.get('team_id')
    FoosballLadder.Match.load matchParams, (err,matches) =>
      @set 'matches', matches
    ```
	
	There's a new concept in here, we can pass parameters to the matches controller in the load function.  Now we only want our
	current teams relevant matches, so we pass in a parameter 'matches_for_team' with our team id.
	
	Then in `matches_controller.rb` we'll add the following to the `index` action:
	```
	def index
	  if params[:matches_for_team]
        team = Team.find params[:matches_for_team]
        @matches = team.team_ones + team.team_twos
      else
        @matches = Match.all
      end

      render json: @matches
    end
	```
	We return both places, and we'll let the JS do the filtering, instead of making two requests to the server.

   
## Back to main#index

 Now we'll make a list of teams, with the ability to challenge.  In `index.html`:
 
 ```
	<div class="span9" data-partial="shared/_team_dashboard"></div>
	<table class="table table-bordered table-striped">
		<tr><td>#</td><td>Team</td><td>Rating</td><td>Challenge!</td></tr>
		<tr data-foreach-team="teams" data-addclass-success="currentUser.team_id | equals team.id">
			<td><span data-bind="indexOf[team]"></span></td>
			<td><a data-route="routes.teams[team]" data-bind="team.name"></a></td>
			<td><span data-bind="team.rating"></span></td>
			<td><button data-hideif="currentUser.team_id | equals team.id" type="button" class="btn">Challenge</button></td>
		</tr>
	</table>
 ```
 
  There's only a few new things in this HTML block:
 
   - `data-addclass-` adds a css class to the node if the binding is true.  In this case we're adding a highlight if it's your own team.
   - `equals` another batman filter that does pretty much what you would expect
   - `[]` operators in the data-bind attribute.  You've seen it in the `data-route` binding but hasn't been explained.
   
   
  The `[]` syntax is for a `Batman.Accessible`, which is a fancy word for an `accessor` that lets you pass objects in.  So in effect those
  `routes.resource[thing]` aren't an array subscript, but a way of passing an object to the `routes.resource` accessor.  We'll see how to
  implement one below:
  
  ```
  @accessor 'indexOf', ->
    new Batman.Accessible (team) =>
      @get('teams').indexOf(team)+1
  ```
  
  Now we can easily have numbers in our team list!
  
## Lookup keypath

  We have a challenge button, but it doesn't do anything.  Now lets hook up an event to it.   Add the attribute `data-event-click="challengePushed"`
  to the button, and a corresponding method in the controller.
  Now we'd like to know what team in this context to challenge.  Remember we have no 'team' object at the controller level, just `teams`, the 
  team object is populated in the `data-foreach`.  So how do get to the `team` object?  We can grab the object via `lookupKeypath`:
  
  ```
  challengePushed: (node, event, view) ->
   team = view.lookupKeypath('team')
  ```
  
  Great, now we have a team object.  Now how do we create a `Match` object and save it?  First lets make sure we have correct associations
  on the `Match` object.  Open up `match.js.coffee`:
  
  ```
  @belongsTo 'team_one', name: 'Team', foreignKey: 'team_one_id'
  @belongsTo 'team_two', name: 'Team', foreignKey: 'team_two_id'
  ```
  
  Now we are saying that `team_one` is a `Team` with the `foreignKey` of 'team_one_id'.  Now you can do the following in the main controller:
  
  ```
  challengePushed: (node, event, view) ->
    team = view.lookupKeypath('team')

    match = new FoosballLadder.Match
    match.set('team_one', FoosballLadder.currentUser.get('team'))
    match.set('team_two', team)
    match.save (err,response) ->
	  
  ```
  
  We'll need to a little bit in `matches_controller.rb` to get around the strong parameters default for rails 4.  Kind of like what we did in
  the `teams_controller`
  
  ```
  def match_params
      params.require(:match).permit(:team_one_id, :team_two_id, :team_one_score, :team_two_score, :team_one_accepted_results, :team_two_accepted_results)
  end
  ```
  
  Now if you hit challenge and check the database, a new `Match` record will be created with all the correct attributes.  And we didn't have to set any
  `id`'s it just worked through the power of batman.
  
  Of course the rest of the ui hasn't updated with our changes, lets change that!
  
  First lets get rid of the challenge button if a match exists for our team versus theirs.  We're going to add another `accessor` that will tell us if
  the team on the line is one we can challenge. This is the line we're going to add to the challenge button.
  
  ```
  data-showif="showChallengeButton[team]
  ```
  
  And we'll add the appopriate accessor onto our controller:
  ```
  @accessor 'showChallengeButton', ->
    new Batman.Accessible (team) =>
      return false if FoosballLadder.currentUser.get('team_id') == team.get('id')
      return !@get('matches')?.some( (m) -> m.get('team_one_id') == team.get('id') or m.get('team_two_id') == team.get('id'))
  ```
  
  So we won't the button if it's our own team, and we won't add it if any of the current 'matches' has us in it.
  
## Score submission

  Since now we can send challenges, we now can record the results somewhere.  We'll go into the dashboard html and it will look like this now:
  
  ```
  <div class="panel panel-default">
	<div class="panel-heading">
		<h4 class="panel-title" data-bind="currentUser.team.name | append ' Dashboard'"></h4>
	</div>
	<div class="panel-body">
		<div class="">
			<div class="alert alert-warning" data-hideif="matches.length">No Matches to record!</div>
			<div data-showif="matches.length">Record your matches below!</div>
			<ul class="list-group">
				<div class="" data-showif="matches.length" class="offset1" data-foreach-match="matches">
					<li class="list-group-item">
						<form data-formfor="match" data-event-submit="updateMatch">
							<div data-showif="match.isTeamOneCurrent">
								<div data-bind="match.opposingTeam.name"></div> 
								<div class="input-group">
									<span class="input-group-addon">My Score:</span>
									<input type="text" class="form-control" data-bind="match.team_one_score" />
									<span class="input-group-addon">Their Score:</span>
									<input type="text" class="form-control" data-bind="match.team_two_score" />
								</div>
							</div>
							<div data-hideif="match.isTeamOneCurrent">
								<div data-bind="match.opposingTeam.name"></div> 
								<div class="input-group">
									<span class="input-group-addon">My Score:</span>
									<input id="team_two_score" type="text" class="form-control" data-bind="match.team_two_score" />
									<span class="input-group-addon">Their Score:</span>
									<input id="team_one_score" type="text" class="form-control" data-bind="match.team_one_score" />
								</div>
							</div>
							<input type="submit" class="btn" value="Submit"/>
						</form>
					</li>
				</div>
			</ul>
		</div>
	</div>
</div>
```

  The big difference now is that we are iterating over the list of matches, and supplying some forms to input the match data.  We now can show it or hide depending
  on the value of `matches.length`.   We'll add the ability to submit the match data via a method in the controller:
  
  ```
  updateMatch: (node, event, view)->
    match = view.lookupKeypath('match')
    match.save (err,response) =>
      @get('matches').remove(match)
      FoosballLadder.Team.load (err,teams) =>
        @set 'teams', teams

  ```
  
  We'll use the `lookupKeypath` method to grab the model from the foreach iteration again.  It will be prepopulated from the magic of data binding, then we'll save it.
  On the response we'll remove the match from the list and reload the teams for the rating calculation.  
  
  We're also going to change the data type on the `matches`, as the `load` method on the model will return a plain old javascript array.  Why?  Well if we don't the rest 
  of the page won't auto update when `matches` changes.  In the `index` action we'll construct a Batman.Set from the returned array like this:
  ```
  matchParams = matches_for_team: FoosballLadder.currentUser.get('team_id'), needs_action: 1
    FoosballLadder.Match.load matchParams, (err,matches) =>
      @set 'matches', new Batman.Set(matches...)
  ```
  
   Now whenever `matches` changes, all of our bindings will update.  You'll notice we added a `needs_action` parameter to the load to indicate to the server that we only
   want `Match` object that require us to submit scores.  We'll have to do a little ruby work now to get the back end up to snuff.
   
   First, the default controller action for create doesn't seem to give us back the entire object.  We can change this behaviour pretty easily by chaning the render in
   the `create` action:
   
   ```
   form.json { render: json: @match, status: :create }
   ```
   
   Now we can grab that object with it's persisted id and shove it into the list of matches that we're interested in.  Now lets add a rating calculation ( I just grabbed
   an ELO rating off the internet. )  And put it into the the `update` action like so:
   
   ```
     def calculate_rating
    if @match.team_one_score > @match.team_two_score
      score = 1
    else
      score = 0
    end

    score_difference = @match.team_two.rating - @match.team_one.rating
    team_one_rating = score -  1.0 / ( (10**(score_difference/400.0))+1)
    team_one_rating *= 20

    score = score == 1 ? 0 : 1

    score_difference = @match.team_one.rating - @match.team_two.rating
    team_two_rating = score -  1.0 / ( (10**(score_difference/400.0) ) + 1 )
    team_two_rating *= 20
    
    @match.team_two.rating += team_two_rating
    @match.team_two.save!
    
    @match.team_one.rating += team_one_rating
    @match.team_one.save!
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    respond_to do |format|
      mp = match_params
      if @match.update(mp)
        format.json { render json: @match }
        if @match.team_one_score and @match.team_two_score
          calculate_rating
        end
      else
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end
 ````
 
  We also have to add a `rating` column to the `teams` table.  So we'll generate a migration like we did in previous tutorials and add the line:
  ```
  add_column :teams, :rating, :decimal, :default => 1200
  ```
  
  We're going to start everyone with a default rating of 1200, we could do 0 but it's kind of odd to have negative ratings.  We're also missing the implementation of
  `get_matches` so let's add that as well:
  
  ```
   def get_matches( needs_action )
    Match.where( '(team_one_id = ? or team_two_id = ?) and (team_one_score IS NULL or team_two_score IS NULL)', id, id )
  end
  ```
  
  

