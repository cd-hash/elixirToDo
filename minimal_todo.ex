defmodule MinimalToDo do
  @moduledoc """

  create_list will instantiate our map which will hold all our to do items

  create_item: creates an item in the map where item.todo is the key and item.notes is the value
  """
  def create_list do
    Agent.start_link(fn -> %{} end)
  end

  def get_item(todo_list, key) do
    Agent.get(todo_list, &Map.get(&1, key)) #returns nil
  end

  def create_item(todo_list, todo, notes \\ "") do
    Agent.update(todo_list, &Map.put(&1, todo, notes))
  end
end
