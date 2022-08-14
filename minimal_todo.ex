defmodule MinimalToDo do
  @moduledoc """

  general todo structure %{todo, %{todo => todo_item, notes => notes, priority => 1}}

  create_list will instantiate our map which will hold all our to do items

  create_item: creates an item in the map where item.todo is the key and item.notes is the value
  """
  def create_list do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_item(key) do
    item = Agent.get(__MODULE__, &Map.get(&1, key))
    case item do
      nil -> {:error, "the item you searched for doesn't exist"}
      _ -> {:ok, item}
    end

  end

  def create_item(todo, priority \\ 5, notes \\ "") do
    item = get_item(todo)
    case item do
      {:error, response} -> Agent.update(__MODULE__, &Map.put(&1, todo, %{todo: todo, notes: notes, priority: priority}))
      {:ok, item} -> {:error, "the item you're trying to add already exists"}
    end
  end
end
