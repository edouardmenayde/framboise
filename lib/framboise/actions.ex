defmodule Actions do
  @callback index(conn :: term, params :: term) :: any
  @callback show(conn :: term, params :: term) :: any
  @callback create(conn :: term, new_record :: term) :: any
  @callback update(conn :: term, record_update :: term) :: any
  @callback delete(conn :: term, params :: term) :: any
end

defmodule Framboise.Actions do
  import Ecto.Query

  @not_found_error_message "Record not found."

  defp to_existing_atom(value) when is_binary(value) do
    case Integer.parse(value) do
      {value, _} ->
        value

      :error ->
        value
        |> String.downcase()
        |> String.to_existing_atom()
    end
  end

  defp to_existing_atom(value) when is_integer(value) do
    value
  end

  defp to_existing_atom(params, key, default) do
    Map.get(params, key, default)
    |> to_existing_atom
  end

  def handle_index(conn, params, model, repo) do
    sort = to_existing_atom(params, "_sort", "id")
    #        order = to_existing_atom(params, "_order", "asc")
    limit = to_existing_atom(params, "_limit", 30)
    start = to_existing_atom(params, "_start", 0)

    order_by = [desc: sort]

    query =
      model
      |> select([r], r)
      |> order_by(^order_by)
      |> limit(^limit)
      |> offset(^start)
      |> distinct(true)

    associations = model.__schema__(:associations)

    query =
      associations
      |> Enum.reduce(
        query,
        fn association, q ->
          q
          |> preload(^association)
        end
      )

    records =
      query
      |> repo.all()

    count =
      model
      |> select([r], count(r.id))
      |> repo.one()

    conn
    |> Plug.Conn.put_resp_header("x-total-count", Integer.to_string(count))
    |> Phoenix.Controller.render("index.json", records: records)
  end

  def handle_show(conn, %{"id" => id}, model, repo) do
    record = repo.get(model, id)

    if record do
      conn
      |> Phoenix.Controller.render("show.json", record: record)
    else
      conn
      |> Explode.with(400, @not_found_error_message)
    end
  end

  def handle_create(conn, new_record, model, repo) do
    changeset = model.changeset(struct!(model, %{}), new_record)

    if changeset.valid? do
      case repo.insert(changeset) do
        {:ok, new_record} ->
          conn
          |> Plug.Conn.put_status(201)
          |> Phoenix.Controller.render("created.json", record: new_record)

        {:error, changeset} ->
          conn
          |> Explode.with(changeset)
      end
    else
      conn
      |> Explode.with(changeset)
    end
  end

  def handle_update(conn, %{"id" => id} = record_update, model, repo) do
    record = repo.get(model, id)

    if record do
      changeset = model.changeset(record, record_update)

      if changeset.valid? do
        case repo.update(changeset) do
          {:ok, updated_record} ->
            Phoenix.Controller.render(conn, "updated.json", record: updated_record)

          {:error, changeset} ->
            conn
            |> Explode.with(changeset)
        end
      else
        conn
        |> Explode.with(changeset)
      end
    else
      conn
      |> Explode.with(400, @not_found_error_message)
    end
  end

  def handle_delete(conn, %{"id" => id}, model, repo) do
    record = repo.get(model, id)

    if record do
      case repo.delete(record) do
        {:ok, deleted_record} ->
          Phoenix.Controller.render(conn, "deleted.json", record: deleted_record)

        {:error, changeset} ->
          conn
          |> Explode.with(changeset)
      end
    else
      conn
      |> Explode.with(400, @not_found_error_message)
    end
  end

  defmacro __using__(opts \\ []) do
    model =
      opts
      |> Keyword.get(:model)

    repo =
      opts
      |> Keyword.get(:repo)

    quote do
      @behaviour Actions

      def index(conn, params) do
        Rest.Actions.handle_index(conn, params, unquote(model), unquote(repo))
      end

      def show(conn, params) do
        Rest.Actions.handle_show(conn, params, unquote(model), unquote(repo))
      end

      def create(conn, new_record) do
        Rest.Actions.handle_create(conn, new_record, unquote(model), unquote(repo))
      end

      def update(conn, record_update) do
        Rest.Actions.handle_update(conn, record_update, unquote(model), unquote(repo))
      end

      def delete(conn, params) do
        Rest.Actions.handle_delete(conn, params, unquote(model), unquote(repo))
      end

      defoverridable Actions
    end
  end
end
