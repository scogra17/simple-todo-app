require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"

configure do
  enable :sessions #enable session support
  set :session_secret, 'secret' #set sessions secret to 'secret', in prod, set in env var
end

helpers do
  def sort_lists(lists, &block)
    complete_lists, incomplete_lists = lists.partition { |list| list_complete?(list) }

    incomplete_lists.each { |list| yield list, lists.index(list) }
    complete_lists.each { |list| yield list, lists.index(list) }
  end

  def sort_todos(todos, &block)
    complete_todos, incomplete_todos = todos.partition { |todo| todo[:completed] }

    incomplete_todos.each { |todo| yield todo, todos.index(todo) }
    complete_todos.each { |todo| yield todo, todos.index(todo) }
  end

  def todos_remaining_count(list)
    list[:todos].count do |todo|
      !todo[:completed]
    end
  end

  def todos_count(list)
    list[:todos].size
  end

  def list_complete?(list)
    todos_count(list) > 0 && todos_remaining_count(list) == 0
  end

  def list_class(list)
    "complete" if list_complete?(list)
  end
end

before do
  session[:lists] ||= []
  @lists = session[:lists]
end

get "/" do
  redirect "/lists"
end

# GET  /lists      -> view all lists
# GET  /lists/new  -> new list form
# POST /lists      -> create new list

# notes: values were chosen because they're "resource based".
# this means the name of the thing being modified is in the url (i.e. list)
# this helps construct a url from an intention, so...

# GET  /lists/1    -> view a single list
# GET  /users      -> view all users
# GET  /users/1    -> view a single user
# GET  /resource_type/id

# POST /lists/:id/todos  -> create new todo (post to collection of thing, like in lists)

# View list of lists
get "/lists" do
  erb :lists, layout: :layout
end

# Return an error message if the name is invalid.
# Return nil if name is valid.
def error_for_list_name(name)
  if !(1..100).cover? name.size
    "The list name must be between 1 and 100 characters."
  elsif session[:lists].any? { |list| list[:name] == name }
    "The list name must be unique."
  end
end

# Return an error message if the name is invalid.
# Return nil if name is valid.
def error_for_todo(name)
  if !(1..100).cover? name.size
    "The todo must be between 1 and 100 characters."
  end
end

def load_list(index)
  list = session[:lists][index] if index && session[:lists][index]
  return list if list

  session[:error] = "The specified list was not found."
  redirect "/lists"
end

# Create a new list
post "/lists" do
  list_name = params[:list_name].strip

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << {name: list_name, todos: []}
    session[:success] = "The list has been created."
    redirect "/lists"
  end
end

# Render the new list form
get "/lists/new" do
  puts "test"
  erb :new_list, layout: :layout
end

# Render a todo list
get "/lists/:id" do
  @list_no = params[:id].to_i
  @list = load_list(@list_no)

  erb :list, layout: :layout
end

# Edit an existing todo list
get "/lists/:id/edit" do
  @list_no = params[:id].to_i
  @list = load_list(@list_no)

  erb :edit_list, layout: :layout
end

# Update an existing todo list
post "/lists/:id" do
  list_no = params[:id].to_i
  list_name = params[:list_name].strip
  @list = load_list(@list_no)

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    @list[:name] = list_name
    session[:success] = "The list name has been changed."
    redirect "/lists/#{list_no}"
  end
end

# Delete a todo list
post "/lists/:id/destroy" do
  list_no = params[:id].to_i
  @lists.delete_at(list_no)
  session[:success] = "The list has been deleted."

  redirect "/lists"
end

# Add item to todo list
post "/lists/:list_id/todos" do
  @list_no = params[:list_id].to_i
  @list = load_list(@list_no)
  text = params[:todo].strip

  error = error_for_todo(text)
  if error
    session[:error] = error
    erb :list, layout: :layout
  else
    @list[:todos] << {name: text, completed: false}
    session[:success] = "The todo was added."
    redirect "/lists/#{@list_no}"
  end
end

# Delete item from todo list
post "/lists/:id/todos/:todo_id/destroy" do
  list_no = params[:id].to_i
  todo_no = params[:todo_id].to_i
  @list = load_list(@list_no)

  @list[:todos].delete_at(todo_no)
  session[:success] = "The todo has been deleted."

  redirect "/lists/#{list_no}"
end

# Update status of a todo
post "/lists/:id/todos/:todo_id" do
  list_no = params[:id].to_i
  todo_no = params[:todo_id].to_i
  @list = load_list(@list_no)
  is_completed = params[:completed] == "true"
  @list[:todos][todo_no][:completed] = is_completed

  session[:success] = "The todo has been updated."
  redirect "/lists/#{list_no}"
end

# Mark all todos as complete
post "/lists/:id/complete_all" do
  list_no = params[:id].to_i
  @list = load_list(@list_no)

  @list[:todos].each do |todo|
    todo[:completed] = true
  end

  session[:success] = "Completed all todos."
  redirect "/lists/#{list_no}"
end
