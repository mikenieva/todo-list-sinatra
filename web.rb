require 'sinatra'
require 'data_mapper'
require 'json'


=begin
	
First of all, this code calls the DataMapper set-up to 
create a SQLite database connection – todo_list.db. 
The model is then defined to create a to-do list 
Item, which comprises an id, content, a done marker 
and the created date. The last line will finalise the 
DataMapper model while auto_upgrade! creates the table and 
also adds new columns (if they are ever added).
	
=end

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/todo_list.db")
class Item
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required => true
	property :done, Boolean, :required => true, :default => false
	property :created, DateTime
end
DataMapper.finalize.auto_upgrade!

=begin

Like some of the early examples, to create the root route 
we’re calling the get method with a route parameter of /. 
Inside this, run a query on the database using the Item 
class, which was generated earlier in the DataMapper model. 
From the database we request all items ordered by the 
created date. This is then set to the @items variable. 
If this is empty, the user is redirected to the /new route 
(which we will create soon) to prevent the index view loading.

=end

get '/?' do
  @items = Item.all(:order => :created.desc)
  redirect '/new' if @items.empty?
  erb :index
end

=begin

There are two elements to this: a get and a post. 
The get will be used to render the form to add new to-do 
items, and the post will handle the post request that 
comes from this form.

There is no logic needed to render the form. 
We set a @title variable that is returned within the 
<h1> tags of the layout view, and then we call 
the new.erb view.

The post needs to create the to-do item in the database. 
DataMapper can handle all this with the create method. 
We pass in params[:content], which is the text from the 
form and also a timestamp using Time.now. After this 
a redirect is done, back to the homepage that will 
show the newly added to-do item.


=end

get '/new/?' do
  @title = "Add todo item"
  erb :new
end

post '/new/?' do
  Item.create(:content => params[:content], :created => Time.now)
  redirect '/'
end

=begin

In this code, we’re using the DataMapper method to fetch 
the to-do item from the database, based on the id given 
by the Ajax call. The done element in the database is 
then set to the opposite of what it previously was: so 
if it was “done” it’s set to “not done”; if it was 
“not done”, “done”. This is represented in the database 
as Boolean: “true” or “false”.


Finally, the item is saved back to the database. We now 
need to return confirmation of what has been done using 
JavaScript Object Notation (JSON). The content type header 
needs to be set to JSON, and, based on the done element 
in the database, the value is set.


The id and value are both added into a hash, which is 
converted to JSON using the to_json method. The to_json 
method is made available as part of the JSON gem. 
Therefore, install it using the command gem install json. 
It also needs requiring at the top of the file using 
the syntax require json.
	

=end

post '/done/?' do
  item = Item.first(:id => params[:id])
  item.done = !item.done
  item.save
  content_type 'application/json'
  value = item.done ? 'done' : 'not done'
  { :id => params[:id], :status => value }.to_json
end


=begin

The first part of the code uses the get method with an :id 
parameter to find the to-do item id from the URL. 
The first item from the database with the matching id is 
then loaded. The final element of the get method calls 
the view delete.erb.

The second part of the code is the post method, and 
this is used as the action for the delete confirmation 
form built in delete.erb. The method checks that the OK 
button has been pressed – rather than the cancel 
button – and then subsequently locates the first to-do 
list item in the database, based on the id in the URL, 
and destroys it before redirecting back to the homepage.	

	
=end

get '/delete/:id/?' do
  @item = Item.first(:id => params[:id])
  erb :delete
end

post '/delete/:id/?' do
  if params.has_key?("ok")
    item = Item.first(:id => params[:id])
    item.destroy
    redirect '/'
  else
    redirect '/'
  end
end