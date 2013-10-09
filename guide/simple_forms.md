# Batman + Rails - Basic controller CRUD actions

  In this tutorial we'll build on what we did in the previous tutorials, as always.  Today we're
	going to be adding a navbar and creating a team.

## Lets add the HTML for a simple navbar

  Since we want the navbar to be outside of the `main#index` we'll add some containers into `batman.html.erb`.
  I used the (twitter-bootstrap)[http://getbootstrap.com] as I generally have no idea what I'm doing when
  it comes to CSS.  Feel free to use your own containers.  We will be editing `batman.html.erb` as it's it's the
  main page for our Batman app, the edits follow:
  
  ```
  <body>
	<div class="container-fluid">
		<div class="row-fluid">
			<div class="span2">
				<div class="navbar-header">
					<a class="navbar-brand">Foosball Ladder</a>
				</div>
				<ul class="nav nav-pills nav-stacked">
					<li><a data-route="routes.teams">Teams</a></li>
					<li><a data-route="routes.users">Users</a></li>
					<li><%= link_to "Sign Out", destroy_user_session_path %></li>
				</ul>
			</div>
			<div data-yield="main"></div>
		</div>
		<script type="text/javascript">
			FoosballLadder.currentUser = FoosballLadder.User.createFromJSON( <%= current_user.to_json.html_safe %> );
			FoosballLadder.run();
		</script>
	</div>
   </div>
   ```
   
   It almost looks like normal HTML, until you see the `data-route` directives.  These correspond with your
   default routes set in `foosball_ladder.js.coffee`, with the relevant lines being:
   ```
   @resources 'teams'
   @resources 'users'
   ```
   These are analgous to the rails like `resources` directives in `routes.rb`.
   
   When you click on one of the links Batman will route you to the correspond controller and view for the resource.
   Lets use the `teams` controller.
   
   We really added a navbar so we wouldn't get stuck on a page, and we never want to hit `reload`, we're a single
   page app baby!
   
## Your first resource controller

  Since we already have a rails controller for `teams`, lets generate one in Batman.
  
  ```
  $ rails generate batman:controller teams
  ```
  
  This will generate a default controller and views.  We won't really need a view, batman will create
  a default view anything it needs.  We'll cover why it's useful later.  Lets start by writing the index.
  
  Open up `batman/controllers/teams_controller.js.coffee` and add the following action:
  ```
  index: (params) ->
    FoosballLadder.load (err, response) =>
	  @set 'teams', team
  ```
  
  For this we'll start by writing the index.html, this will live in the `batman/html/teams/index.html`.
  Lets start with something, simple like the `main#index` page.
  
  ```
  <div class="span10">
	<h1 class="span9">Teams</h1>
	<div class="span6">
		<div class="row-fluid">
			<div class="btn-group pull-right">
				<button type="button" class="btn btn-default" data-event-route="route.teams.new">Add Team</button>
			</div>
		</div>
		<ul class="list-group">
			<div data-foreach-team="teams">
				<li class="list-group-item"><a data-route="routes.teams[team]" data-bind="team.name"></a></li>
			</div>
		</ul>
	</div>
  </div>
  ```
  
  There's a few new things, I'll explain them below.
  
  - `data-route="route.teams.new"` This will dispatch the new action.
  - `data-route="route.teams[team]"` We've seen this before, but not in this context.  It will route to the `show` 
	                                 action of the teams resource.  Hover over the link and you'll see the RESTful URL.
				 

  _NOTE_: If you hit refresh in this page and get something like this:
	  You'll need to move the following line in `routes.rb` to above the `resource` directives.
	  
	  ```
	  get "(*redirect_path)", to: "batman#index", constraints: lambda { |request| request.format == "text/html" }
	  ```
	  
## Lets do a simple form submission

  We're going to hook a way to make a new team.

  So lets start by adding the action to the controller.  We'll make a new `Team` and add that to the controller
  so that we can bind to it's attributes in the HTML.
  
  ```
  new: (params) ->
    team = new FoosballLadder.Team
	@set 'team', team
  ```
  
  Now to write some HTML, make a new file in `batman/html/teams/new.html`.
  
  ```
  <div class="span10">
	<h1 class="span9">New Team</h1>
	<div class="row-fluid">
		<form data-formfor-team="team" data-event-submit="create">
			<div class="span9">
				<div class="btn-group pull-right">
					<button type="button" class="btn btn-default" data-route="routes.teams">Cancel</button>
					<input class="btn btn-default" type="submit" value="Save" />
				</div>
			</div>
			<div class="span8">
				<div class="input-group">
					<input type="text" class="form-control" data-bind="team.name" placeholder="Team name"/>
				</div>
			</div>
		</form>
    </div>
    ```
   
  Now you can see more of the data-bind in action and the form attribute.  We use a `data-formfor` to indicate
  the form.  The `data-event-submit` will call the method `create` on the controller.
   
  Now in the `create` method on the `teams_controller.js.coffee`.  This is how my method looks:
  ```
  create: ->
    @get('team').save (err,team) ->
	  Batman.redirect FoosballLadder.get('routes.teams.path')
  ```
  
  Now on the rails side we have to use the strong parameter code in the `teams_controller`.
  
  ```
  def create
    @team = Team.new( team_params)
    ...
	
  def team_params
    params.require(:team).permit(:users,:name)
  end
  ```

  Now you should be able to create a team, and see the newly created one in the `teams` index.


## A show page
  
  This part will be similar to the `main#index` that we did, and the new page above.  In a future tutorial when we add
  the ability to add matches we can add that information here as well.  First lets define the action in the `teams_controller`, like so:
  ```
  show: (params) ->
    FoosballLadder.find params.id, (err,team) =>
	  @set 'team', team
	  
  deleteTeam: (node, event, view) ->
    @get('team').destroy (err,response) ->
	  Batman.redirect FoosballLadder.get('routes.teams.path')
  ```
  If you look at the url from the index page you can see the RESTful url looks something like this: `/teams/1`.  That
  will get passed in params as the id, from there you can use the `find` method on the model class to look up that particular instance.  The HTML will be in a correspond `show.html` and it looks like:
  
  ```
  <div class="span10">
	<h1 class="span9" data-bind="team.name"></h1>
	<div class="row-fluid">
		<form data-formfor-team="team" data-event-submit="create">
			<div class="span9">
				<div class="btn-group pull-right">
					<button type="button" class="btn btn-default" data-event-click="deleteTeam">Delete</button>
					<input class="btn btn-default" type="submit" value="Save" />
				</div>
			</div>
			<div class="span8">
				<div class="input-group">
					<input type="text" class="form-control" data-bind="team.name" placeholder="Team name"/>
				</div>
			</div>
			<div class="span9">
				<h4>Users</h4>
				<ul class="list-group">
					<div data-foreach-user="team.users">
						<li class="list-group-item"><a data-route="routes.users[user]" data-bind="user.email"></a></li>
					</div>
				</ul>
			</div>
		</form>
	</div>
	```
  
  Now for something cool, if you edit the `name`, the title auto update at the same time.  Behold the power of bindings!
  We also allowed the users list to be a clickable route to the users show page, although it doesn't exist yet. Delete now works as well!

  Since the object already exists, this will go through the update method on the ruby side. All we have to do is make sure we're using the `team_params` instead of just passing the attributes in like in rails 3.

I'll leave the `users` controller up to you, but it will be mostly the same.  Though I wouldn't users to delete other users!


