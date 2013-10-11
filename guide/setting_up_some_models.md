# Simple Associations: 

  In this tutorial we'll extend what we did in tutorial #1 and generate some models
  for use in our foosball-ladder project.
  
## Handle login

  Since we are using `devise` it can handle the login for us.  At the top  of
  `application_controller.rb` add the line:
  ```
  before_filter :authenticate_user!
  ```

  Now if you go to your website, you should get an login screen.  Follow the sign in and
  you will see the batman.js starting guide like you did in the last tutorial.
  
  Lets delete all of that, in `batman/html/main/index.html` and replace it with some our 
  own html.  You could do something like this:
  
  ```
  <div>
	<h1>Welcome to the Foosball Ladder</h1>
  </div>
  ```
  
  Note that we don't need the normal html elements, as this will be embedded in another html page
  (we're making a single page app dawg! )
  
  Now when you go to the page it should like this:
  
  
  
## Let's make a batman model (finally)

  We can login now (hurray), now lets add some context to that starting page.  It would be nice
  to greet the user by their email.  How do we do that in BatmanJS?  We'll need to setup a 
  batman model that mimics the ruby model.  You can do it manually, or use the scaffold generator!
  Models will live in `batman/models` and follow a similar naming scheme.  To generate
  the model and some corresponding files run the following command:
  
  ```
  $ rails generate batman:model User email:string
  ```
  
  This should create a `user.js.coffee` in the `batman/models` directory.  Let's expose the
  `email` field so that we have something to show.
  
  Add the following to the model:
  
  ```
  @encode 'email'
  ```
  
  This will tell batman that we will get an `email` field in the json object describing the `User`
  
  Now we'll have to pass the user into batman somehow, normally for something like the current user
  we'll hook into `devise` and grab it.
  
  Open up `batman.html.erb` and add the following line:
  
  ```
  FoosballLadder.currentUser = FoosballLadder.User.createFromJSON( <%= current_user.to_json.html_safe %> );
  ```
  
  Now load your main page again and pop open the javascript console ( you'll be using this a lot for debugging
  so get used to it!)
  
  If you type in FoosballLadder, you'll see the top level object that describes your application (it's also known
  as `Batman.currentApp`.)  Now type in `FoosballLadder.currentUser`.  You should see something like this:
  
  
  Great, we have our current user in batman land now!
  
## A simple data-bind

  Now how do we get that displayed in the HTML?  We'll lightly introduce the concepts of `data-bind` here.
  A `data-bind` represents a two way binding to a corresponding javascript object.  To demonstrate this
  we will add a message to display a welcome message to the current user.
  
  Open `main/index.html` and we'll add the following line:
  
  ```
  <p>Hello!: <span data-bind="currentUser.email"></span></p>
  ```
  
  Now if you reload the page you should get the following screen:
  
  There's a lot of power and flexibility in the binding system, but we'll gloss over it for now.  The most
  important thing to know is that if `currentUser.email` changes, the corresponding `data-bind` will 
  reflect the change as well, which is pretty awesome!

## Lets add some associations

  A foosball ladder isn't very good with some Teams, so lets add a model in rails called `Team`, and associate
  it with the `User` object.  A `Team` will have many `Users`, and a `User` will have one `Team`.
  
  To generate a default rails scaffold we can do the following:
  
  ```
  $ rails generate scaffold Team name:string
  $ rake db:migrate
  ```
  Now we'll have a `Team` object with a name.  Lets make a batman object that corresponds to the ruby model.
  ```
  $ rails generate batman:model Team
  ```
  
### A little forray back into data-binds

  So how do we make sure that works?  Lets introduce the concept of a `data-foreach` binding.
  This works pretty much how you'd expect, I'll show an example below:
  
  ```
  <div data-foreach-team="teams">
    <p><span data-bind="team.name"></span></p>
  </div>
  ```
  This is a little like a for loop in another language.  In the scope of that div, it will iterator over
  "teams", with the name "team" for each iteration.  We'll also bind the name of the team so that we can
  see it.
  
  Use my `populate.rake` file in the foosball-ladder project, I'll leave it out for brevity.  It's just making
  a bunch of users and teams with random names.
  
  Now how do we get that data into the binding?  Open up `main_controller.js.coffee` and look at the `index` option.
  Add the following code which will load the all the `Team`s and set it on the controller, which the data bind will
  access.
  
  ```
  index: (params) ->
    FoosballLadder.Team.load (err,teams) =>
	  @set 'teams', teams
  ```
  
  Now you should see something like this:
  
  Cool, now you have some data in batman land from ruby land!
  
### back to associations!  
  Lets add the has_many relationship to `Team`, add the following to `team.rb`
  ```
  has_many :users
  ```

  But wait, we don't have the corresponding relationship on the `User` object.  We'll need to generate a migration
  that adds the key to the `user` table.
  
  ```
  $ rails generate migration AddTeamToUsers
  ```
  
  Now open up the created migration in `db/migrate` ( the console will tell you the filename.) And
  add the following line in the change method:
  
  ```
  add_reference :users, :team, index: true
  ```

  Now run the migration (`rake db:migrate` if you forgot.) You should now have added a `team_id` column to 
  the `users` table.  Now add the relationship into `user.rb`, in this case:
  
  ```
  belongs_to :team
  ```
  
  Ok that was a lot of rails, now back to batman.  Let's add the relation to both the `User` and the `Team`.
  In `user.js.coffee` add:
  ```
  @belongsTo 'team'
  ```
  and in `team.js.coffee` add:
  ```
  @hasMany 'users', foreignKey: 'team_id'
  ```
  The `foreignKey` specifies the table column we are associating to.
  
  Let's say we'd like to print the names of the users in each team beside the team name.  Notice that 'users' is
  a `@hasMany` which means there's multiple users for each team.
  
  Lets edit some HTML, to add the users for each team!  It's similar to the team iteration, just nested.
  I've shown it below:
   
  ```
  <div>
   <h1>Welcome to the Foosball Ladder</h1>
   <div>
 	<p>Hello!: <span data-bind="currentUser.email"></span></p>
	<div data-foreach-team="teams">
      Team Name: <span data-bind="team.name"></span><br/>
      Users: 
	  <div data-foreach-user="team.users">
	    <span data-bind="user.email"></span></div>
	   </div>
	</div>
   </div>
    ```
	
  As you can see we can grab the `team` object from the iteration above and iterate over it's `association`.
  You will need to add some extra code into the index action in the `users_controller`, it's pretty easy to derive
  but here it is:
  ```
  def index
    if params[:team_id]
      @users = User.where('team_id = ?', params[:team_id])
    else
      @users = User.all
    end
    respond_to do |format|
      format.json { render json: @users }
    end
  end
  ```
  
  
