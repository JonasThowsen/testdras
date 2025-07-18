defmodule DrasMvpWeb.CsvImportLive do
  use DrasMvpWeb, :live_view
  alias DrasMvp.Academic

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:import_results, nil)
     |> assign(:validation_errors, [])
     |> assign(:preview_data, nil)
     |> assign(:import_status, :waiting)
     |> assign(:page_title, "CSV Import")
     |> allow_upload(:csv_file,
       accept: ~w(.csv),
       max_entries: 1,
       max_file_size: 10_000_000
     )}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :csv_file, ref)}
  end

  def handle_event("parse-csv", _params, socket) do
    case uploaded_entries(socket, :csv_file) do
      {[entry], []} ->
        file_path =
          consume_uploaded_entry(socket, entry, fn %{path: path} ->
            {:ok, File.read!(path)}
          end)

        case parse_and_validate_csv(file_path) do
          {:ok, data, suggestions} ->
            {:noreply,
             socket
             |> assign(:preview_data, data)
             |> assign(:validation_errors, suggestions)
             |> assign(:import_status, :preview)}

          {:error, reason} ->
            {:noreply,
             socket
             |> put_flash(:error, "CSV parsing failed: #{reason}")
             |> assign(:import_status, :error)}
        end

      _ ->
        {:noreply, put_flash(socket, :error, "Please select a CSV file to upload")}
    end
  end

  def handle_event("confirm-import", _params, socket) do
    case socket.assigns.preview_data do
      nil ->
        {:noreply, put_flash(socket, :error, "No data to import")}

      data ->
        case process_csv_import(data) do
          {:ok, results} ->
            {:noreply,
             socket
             |> assign(:import_results, results)
             |> assign(:import_status, :complete)
             |> put_flash(:info, "CSV import completed successfully!")}

          {:error, reason} ->
            {:noreply,
             socket
             |> put_flash(:error, "Import failed: #{reason}")
             |> assign(:import_status, :error)}
        end
    end
  end

  def handle_event("reset-import", _params, socket) do
    {:noreply,
     socket
     |> assign(:preview_data, nil)
     |> assign(:validation_errors, [])
     |> assign(:import_results, nil)
     |> assign(:import_status, :waiting)}
  end

  defp parse_and_validate_csv(csv_content) do
    try do
      rows =
        csv_content
        |> String.split("\n")
        |> Enum.map(&String.split(&1, ","))
        |> Enum.reject(&(length(&1) == 1 and hd(&1) == ""))

      case rows do
        [] ->
          {:error, "CSV file is empty"}

        [header | data_rows] ->
          parsed_data =
            Enum.map(data_rows, fn row ->
              Enum.zip(header, row) |> Enum.into(%{})
            end)

          suggestions = validate_csv_data(parsed_data)
          {:ok, parsed_data, suggestions}
      end
    rescue
      e ->
        {:error, "Failed to parse CSV: #{Exception.message(e)}"}
    end
  end

  defp validate_csv_data(data) do
    Enum.with_index(data, 1)
    |> Enum.flat_map(fn {row, index} ->
      validate_row(row, index)
    end)
  end

  defp validate_row(row, row_num) do
    errors = []

    errors =
      if Map.get(row, "course_code", "") == "" do
        [
          %{
            row: row_num,
            field: "course_code",
            message: "Course code is required",
            suggestion: "Add a valid course code like 'MED-1001'"
          }
        ] ++ errors
      else
        errors
      end

    errors =
      if Map.get(row, "exam_date", "") != "" do
        case Date.from_iso8601(Map.get(row, "exam_date")) do
          {:error, _} ->
            [
              %{
                row: row_num,
                field: "exam_date",
                message: "Invalid date format",
                suggestion: "Use YYYY-MM-DD format like '2024-12-15'"
              }
            ] ++ errors

          {:ok, _} ->
            errors
        end
      else
        errors
      end

    student_count = Map.get(row, "student_count", "0")

    if student_count != "" and not String.match?(student_count, ~r/^\d+$/) do
      [
        %{
          row: row_num,
          field: "student_count",
          message: "Student count must be a number",
          suggestion: "Enter a whole number like '25'"
        }
      ] ++ errors
    else
      errors
    end
  end

  defp process_csv_import(data) do
    results = %{
      processed: 0,
      created: 0,
      updated: 0,
      errors: []
    }

    try do
      Enum.reduce(data, results, fn row, acc ->
        case import_exam_record(row) do
          {:ok, :created} ->
            %{acc | processed: acc.processed + 1, created: acc.created + 1}

          {:error, reason} ->
            error = %{row: row, reason: reason}
            %{acc | processed: acc.processed + 1, errors: [error | acc.errors]}
        end
      end)
      |> then(fn final_results -> {:ok, final_results} end)
    rescue
      e ->
        {:error, Exception.message(e)}
    end
  end

  defp status_class(status) do
    case status do
      :waiting -> "bg-gray-400"
      :preview -> "bg-yellow-500"
      :complete -> "bg-green-500"
      :error -> "bg-red-500"
    end
  end

  defp import_exam_record(row) do
    # For now, we'll create a simple exam record
    # In a real system, you'd lookup/create the course first
    exam_attrs = %{
      # Would lookup by course_code
      course_id: 1,
      exam_date: parse_date(Map.get(row, "exam_date", "")),
      exam_type: Map.get(row, "exam_type", "written"),
      student_count: parse_integer(Map.get(row, "student_count", "0")),
      examiner_hours: parse_decimal(Map.get(row, "examiner_hours", "0")),
      grading_hours: parse_decimal(Map.get(row, "grading_hours", "0")),
      import_batch_id: generate_batch_id()
    }

    case Academic.create_exam_record(exam_attrs) do
      {:ok, _exam_record} -> {:ok, :created}
      {:error, _changeset} -> {:error, "Failed to create exam record"}
    end
  end

  defp parse_date(""), do: nil

  defp parse_date(date_str) do
    case Date.from_iso8601(date_str) do
      {:ok, date} -> date
      {:error, _} -> nil
    end
  end

  defp parse_integer(""), do: 0

  defp parse_integer(str) do
    case Integer.parse(str) do
      {int, _} -> int
      :error -> 0
    end
  end

  defp parse_decimal(""), do: Decimal.new("0")

  defp parse_decimal(str) do
    case Decimal.parse(str) do
      {decimal, _} -> decimal
      :error -> Decimal.new("0")
    end
  end

  defp generate_batch_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16() |> String.downcase()
  end
end
