defmodule DrasMvpWeb.CsvImportLive do
  use DrasMvpWeb, :live_view
  alias DrasMvp.Academic

  def mount(_params, _session, socket) do
    current_year = Academic.get_current_academic_year()

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:import_results, nil)
     |> assign(:validation_errors, [])
     |> assign(:preview_data, nil)
     |> assign(:import_status, :waiting)
     |> assign(:current_year, current_year)
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

        case parse_and_validate_csv(file_path, socket.assigns.current_year) do
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
        case process_csv_import(data, socket.assigns.current_year) do
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

  defp parse_and_validate_csv(csv_content, current_year) do
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
          # Clean headers and data
          header = Enum.map(header, &String.trim/1)

          parsed_data =
            Enum.map(data_rows, fn row ->
              row = Enum.map(row, &String.trim/1)
              Enum.zip(header, row) |> Enum.into(%{})
            end)
            |> Enum.reject(&empty_row?/1)

          suggestions = validate_csv_data(parsed_data, current_year)
          {:ok, parsed_data, suggestions}
      end
    rescue
      e ->
        {:error, "Failed to parse CSV: #{Exception.message(e)}"}
    end
  end

  defp empty_row?(row) do
    row
    |> Map.values()
    |> Enum.all?(&(&1 == "" or is_nil(&1)))
  end

  defp validate_csv_data(data, current_year) do
    Enum.with_index(data, 1)
    |> Enum.flat_map(fn {row, index} ->
      validate_row(row, index, current_year)
    end)
  end

  defp validate_row(row, row_num, current_year) do
    errors = []

    # Validate course code
    errors =
      case Map.get(row, "course_code", "") do
        "" ->
          [
            validation_error(
              row_num,
              "course_code",
              "Course code is required",
              "Add a valid course code like 'MED-1001'"
            )
          ] ++ errors

        course_code ->
          # Check if course exists
          case find_course_by_code(course_code, current_year) do
            nil ->
              [
                validation_error(
                  row_num,
                  "course_code",
                  "Course not found",
                  "Course '#{course_code}' doesn't exist. Create it first or check the code."
                )
              ] ++ errors

            _course ->
              errors
          end
      end

    # Validate exam date
    errors =
      case Map.get(row, "exam_date", "") do
        "" ->
          errors

        date_str ->
          case Date.from_iso8601(date_str) do
            {:error, _} ->
              [
                validation_error(
                  row_num,
                  "exam_date",
                  "Invalid date format",
                  "Use YYYY-MM-DD format like '2024-12-15'"
                )
              ] ++ errors

            {:ok, _} ->
              errors
          end
      end

    # Validate student count
    student_count = Map.get(row, "student_count", "0")

    errors =
      if student_count != "" and not String.match?(student_count, ~r/^\d+$/) do
        [
          validation_error(
            row_num,
            "student_count",
            "Student count must be a number",
            "Enter a whole number like '25'"
          )
        ] ++ errors
      else
        errors
      end

    # Validate examiner hours
    examiner_hours = Map.get(row, "examiner_hours", "0")

    errors =
      if examiner_hours != "" and not valid_decimal?(examiner_hours) do
        [
          validation_error(
            row_num,
            "examiner_hours",
            "Examiner hours must be a number",
            "Enter a decimal number like '8.5'"
          )
        ] ++ errors
      else
        errors
      end

    # Validate grading hours
    grading_hours = Map.get(row, "grading_hours", "0")

    errors =
      if grading_hours != "" and not valid_decimal?(grading_hours) do
        [
          validation_error(
            row_num,
            "grading_hours",
            "Grading hours must be a number",
            "Enter a decimal number like '12.0'"
          )
        ] ++ errors
      else
        errors
      end

    errors
  end

  defp validation_error(row, field, message, suggestion) do
    %{
      row: row,
      field: field,
      message: message,
      suggestion: suggestion
    }
  end

  defp valid_decimal?(str) do
    case Float.parse(str) do
      {_float, _} ->
        true

      :error ->
        case Integer.parse(str) do
          {_int, _} -> true
          :error -> false
        end
    end
  end

  defp find_course_by_code(course_code, current_year) do
    if current_year do
      Academic.find_course_by_code(course_code, current_year.id)
    else
      nil
    end
  end

  defp process_csv_import(data, current_year) do
    results = %{
      processed: 0,
      created: 0,
      updated: 0,
      errors: []
    }

    batch_id = generate_batch_id()

    try do
      Enum.reduce(data, results, fn row, acc ->
        case import_exam_record(row, current_year, batch_id) do
          {:ok, :created} ->
            %{acc | processed: acc.processed + 1, created: acc.created + 1}

          {:ok, :updated} ->
            %{acc | processed: acc.processed + 1, updated: acc.updated + 1}

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

  defp import_exam_record(row, current_year, batch_id) do
    course_code = Map.get(row, "course_code", "")

    case find_course_by_code(course_code, current_year) do
      nil ->
        {:error, "Course not found: #{course_code}"}

      course ->
        exam_attrs = %{
          course_id: course.id,
          exam_date: parse_date(Map.get(row, "exam_date", "")),
          exam_type: Map.get(row, "exam_type", "written"),
          student_count: parse_integer(Map.get(row, "student_count", "0")),
          examiner_hours: parse_decimal(Map.get(row, "examiner_hours", "0")),
          grading_hours: parse_decimal(Map.get(row, "grading_hours", "0")),
          import_batch_id: batch_id,
          status: "imported"
        }

        case Academic.create_exam_record(exam_attrs) do
          {:ok, _exam_record} ->
            {:ok, :created}

          {:error, changeset} ->
            error_msg = extract_changeset_error(changeset)
            {:error, "Failed to create exam record: #{error_msg}"}
        end
    end
  end

  defp extract_changeset_error(changeset) do
    changeset.errors
    |> Enum.map(fn {field, {message, _}} -> "#{field} #{message}" end)
    |> Enum.join(", ")
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
    case Float.parse(str) do
      {float, _} ->
        Decimal.from_float(float)

      :error ->
        case Integer.parse(str) do
          {int, _} -> Decimal.new(int)
          :error -> Decimal.new("0")
        end
    end
  end

  defp generate_batch_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16() |> String.downcase()
  end

  defp status_class(status) do
    case status do
      :waiting -> "bg-gray-400"
      :preview -> "bg-yellow-500"
      :complete -> "bg-green-500"
      :error -> "bg-red-500"
    end
  end
end
