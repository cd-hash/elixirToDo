defmodule MinimalToDo do
  use Agent
  @moduledoc """

  general todo structure %{todo, %{todo => todo_item, notes => notes, priority => 1}}

  create_list/0 creates a new list
  create_list/1 creates a list pre filled with the data stored in the .csv file passed

  create_item: creates an item in the map where item.todo is the key and item.notes is the value

  fill_initial_map: the first func adds the default args needed and then returns and calls the func with all args
  fill_initial_map/2 returns our map if it receives an empty list in the first arg this is our base case
  fill_initial_map/2 is our core logic where we split our todo params, fill the map and call the our func with the rest of the list

  get_item/1 checks if the item you searched for exists and returns it if it does

  delete_item/1 takes a list of todos and deletes them from our todo list
  """

  def get_item(key) do
    item = Agent.get(__MODULE__, &Map.get(&1, key))
    case item do
      nil -> IO.puts("the item #{key} you searched for doesn't exist")
      _ -> IO.puts("todo: #{item[:todo]}, notes: #{item[:notes]}, priority: #{item[:priority]}")
    end
    get_command()
  end

  defp item_exists(todo_item) do
    item = Agent.get(__MODULE__, &Map.get(&1, todo_item))
    case item do
      nil -> {:error, "the item #{item} you searched for doesn't exist"}
      _ -> {:ok, item}
    end
  end

  def create_item(todo, priority \\ 5, notes \\ "") do
    item = item_exists(todo)
    case item do
      {:error, _} -> Agent.update(__MODULE__, &Map.put(&1, todo, %{todo: todo, notes: notes, priority: priority}))
      {:ok, _} -> IO.puts("the item #{todo} you're trying to add already exists")
    end
    get_command()
  end

  defp fill_initial_map(todo_items, map \\ %{}) # returns the function with all default fields filled in and calls itself
  defp fill_initial_map([], map), do: map
  defp fill_initial_map([item | rest], map) do
    [todo_item, notes, prio] = String.split(item, ",")
    map = Map.put(map, todo_item, %{todo: todo_item, notes: notes, priority: prio})
    fill_initial_map(rest, map)
  end

  def create_list do
    Agent.start(fn -> %{} end, name: __MODULE__)
  end

  def create_list(file_path) do
    [_header | contents] = File.read!(file_path) |> String.split("\r\n")
    Agent.start(fn -> fill_initial_map(contents) end, name: __MODULE__)
  end

  def delete_item(todo_item) do
    Agent.update(__MODULE__, &Map.drop(&1, [todo_item]))
    get_command()
  end

  def quit do
    Agent.stop(__MODULE__)
  end

  def prepare_csv() do
    headers = ["todo", "notes", "priority"]
    todo_items = Agent.get(__MODULE__, &Map.keys(&1))
    item_rows = Enum.map(todo_items, fn item ->
      [item | Agent.get(__MODULE__, &Map.values(&1[item]))]
    end)
    rows =[headers | item_rows]
    row_strings = Enum.map(rows, &(Enum.join(&1, ",")))
    Enum.join(row_strings, "\n")
  end

  def save_csv(prepared_data) do
    filename = IO.gets("what is the name of this todo list") |> String.trim
    case File.write(filename, prepared_data) do
      :ok -> IO.puts("CSV saved")
      {:error, _reason} -> IO.puts("could not save file #{filename}")
    end
    get_command()
  end

  def get_command do
    Agent.get(__MODULE__, fn state -> state end)
    prompt = "Type the first letter of the command you want to do.\n e.g. R)ead a todo, A)dd a todo, D)elete a todo, S)ave this list, Q)uit\n"
    command = IO.gets(prompt)
      |> String.trim
      |> String.downcase

    case command do
      "r" -> IO.gets("what item do you want to see?\n") |> String.trim |> get_item
      "a" -> IO.gets("what is the name of this todo?\n") |> String.trim |> create_item()
      "d" -> IO.gets("what is the name of the todo you want to delete\n") |> String.trim |> delete_item
      "s" -> prepare_csv() |> save_csv()
      "q" -> IO.puts("goodbye")
      _ -> get_command()
    end
  end

  def main do
    start_from_file = IO.gets("do you want to start from a previous list or create a new one y/n: ")
    |> String.trim
    |> String.downcase
    case start_from_file do
      "y" -> IO.gets("Name of .csv to load: ") |> String.trim |> create_list()
      "n" -> create_list()
    end
    get_command()
  end
end
