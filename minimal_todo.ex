defmodule MinimalToDo do
  @moduledoc """

  general todo structure %{todo, %{todo => todo_item, notes => notes, priority => 1}}

  create_list/0 creates a new list
  create_list/1 creates a list pre filled with the data stored in the .csv file passed

  create_item: creates an item in the map where item.todo is the key and item.notes is the value
  """

  def get_item(key) do
    item = Agent.get(__MODULE__, &Map.get(&1, key))
    case item do
      nil -> {:error, "the item #{item} you searched for doesn't exist"}
      _ -> {:ok, item}
    end
  end

  def create_item(todo, priority \\ 5, notes \\ "") do
    item = get_item(todo)
    case item do
      {:error, _} -> Agent.update(__MODULE__, &Map.put(&1, todo, %{todo: todo, notes: notes, priority: priority}))
      {:ok, item} -> {:error, "the item #{item} you're trying to add already exists"}
    end
  end

  defp fill_initial_map(todo_items, map \\ %{}) # returns the function with all default fields filled in and calls itself
  defp fill_initial_map([], map), do: map
  defp fill_initial_map([item | rest], map) do
    [todo_item, notes, prio] = String.split(item, ",")
    map = Map.put(map, todo_item, %{todo: todo_item, notes: notes, priority: prio})
    fill_initial_map(rest, map)
  end

  def create_list do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def create_list(file_path) do
    [header | contents] = File.read!(file_path) |> String.split("\r\n")
    Agent.start_link(fn -> fill_initial_map(contents) end, name: __MODULE__)
  end

  def delete_item(todo_item) do
    Agent.update(__MODULE__, &Map.drop(&1, [todo_item]))
  end

  def main do
    start_from_file = IO.gets("do you want to start from a previous list or create a new one y/n: ")
    |> String.trim
    |> String.downcase
    case start_from_file do
      "y" -> IO.gets("Name of .csv to load: ") |> String.trim |> create_list()
      "n" -> create_list()
    end
  end
end
