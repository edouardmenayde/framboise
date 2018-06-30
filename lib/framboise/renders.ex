defmodule Framboise.Renders do
  def strip_meta(record) do
    record
    |> Map.delete(:__meta__)
  end

  def to_json(record, module) do
    record
    |> module.to_json
  end

  def render_index(records, module) do
    records
    |> Enum.map(fn (record) -> Framboise.Renders.to_json(record, module) end)
  end

  defp render_single(record, module) do
    record
    |> Framboise.Renders.to_json(module)
  end

  def render_created(record, module) do
    record
    |> render_single(module)
  end

  def render_updated(record, module) do
    record
    |> render_single(module)
  end

  def render_deleted(record, module) do
    record
    |> render_single(module)
  end

  defmacro __using__(_opts) do
    quote do
      def to_json(record) do
        record
        |> Framboise.Renders.strip_meta
      end

      def render("index.json", %{records: records}) do
        records
        |> Framboise.Renders.render_index(__MODULE__)
      end

      def render("show.json", %{record: record}) do
        record
        |> Framboise.Renders.render_show(__MODULE__)
      end

      def render("created.json", %{record: record}) do
        record
        |> Framboise.Renders.render_created(__MODULE__)
      end

      def render("updated.json", %{record: record}) do
        record
        |> Framboise.Renders.render_updated(__MODULE__)
      end

      def render("deleted.json", %{record: record}) do
        record
        |> Framboise.Renders.render_deleted(__MODULE__)
      end

      defoverridable to_json: 1
    end
  end
end
