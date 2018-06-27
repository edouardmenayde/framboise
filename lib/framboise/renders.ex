defmodule Framboise.Renders do
  defmacro __using__(_opts) do
    quote do
      def to_json(record) do
        record
        |> Map.delete(:__meta__)
      end

      def render("index.json", %{records: records}) do
        records
        |> Enum.map(&to_json/1)
      end

      def render("show.json", %{record: record}) do
        record
        |> to_json
      end

      def render("created.json", %{record: record}) do
        record
        |> to_json
      end

      def render("updated.json", %{record: record}) do
        record
        |> to_json
      end

      def render("deleted.json", %{record: record}) do
        record
        |> to_json
      end

      defoverridable to_json: 1
    end
  end
end
