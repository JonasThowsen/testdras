defmodule DrasMvpWeb.AcademicYearLive do
  use DrasMvpWeb, :live_view
  alias DrasMvp.Academic

  @impl true
  def mount(_params, _session, socket) do
    academic_years = Academic.list_academic_years()
    current_year = get_current_academic_year(academic_years)

    setup_progress =
      if current_year do
        calculate_setup_progress(current_year)
      else
        %{
          academic_year: 0,
          study_programs: 0,
          courses: 0,
          classes: 0,
          teaching_assignments: 0,
          exam_data: 0,
          exam_setup: 0,
          staff_management: 0,
          resource_allocation: 0,
          reports: 0,
          overall: 0
        }
      end

    {:ok,
     socket
     |> assign(:academic_years, academic_years)
     |> assign(:current_year, current_year)
     |> assign(:setup_progress, setup_progress)
     |> assign(:show_create_form, false)
     |> assign(:form, to_form(%{}))}
  end

  @impl true
  def handle_event("show_create_form", _params, socket) do
    {:noreply, assign(socket, :show_create_form, true)}
  end

  @impl true
  def handle_event("hide_create_form", _params, socket) do
    {:noreply, assign(socket, :show_create_form, false)}
  end

  @impl true
  def handle_event(
        "create_academic_year",
        %{"name" => name, "start_date" => start_date, "end_date" => end_date},
        socket
      ) do
    case Academic.create_academic_year(%{
           name: name,
           start_date: Date.from_iso8601!(start_date),
           end_date: Date.from_iso8601!(end_date),
           status: "planning",
           is_active: false
         }) do
      {:ok, _academic_year} ->
        academic_years = Academic.list_academic_years()
        current_year = get_current_academic_year(academic_years)
        setup_progress = if current_year, do: calculate_setup_progress(current_year), else: %{}

        {:noreply,
         socket
         |> assign(:academic_years, academic_years)
         |> assign(:current_year, current_year)
         |> assign(:setup_progress, setup_progress)
         |> assign(:show_create_form, false)
         |> put_flash(:info, "Academic year created successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error creating academic year")}
    end
  end

  @impl true
  def handle_event("delete_academic_year", %{"id" => id}, socket) do
    academic_year = Academic.get_academic_year!(id)

    case Academic.delete_academic_year(academic_year) do
      {:ok, _} ->
        academic_years = Academic.list_academic_years()
        current_year = get_current_academic_year(academic_years)
        setup_progress = if current_year, do: calculate_setup_progress(current_year), else: %{}

        {:noreply,
         socket
         |> assign(:academic_years, academic_years)
         |> assign(:current_year, current_year)
         |> assign(:setup_progress, setup_progress)
         |> put_flash(:info, "Academic year deleted successfully!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error deleting academic year")}
    end
  end

  @impl true
  def handle_event("set_active_year", %{"id" => id}, socket) do
    # First, deactivate all years
    Enum.each(socket.assigns.academic_years, fn year ->
      Academic.update_academic_year(year, %{is_active: false})
    end)

    # Then activate the selected year
    academic_year = Academic.get_academic_year!(id)

    case Academic.update_academic_year(academic_year, %{is_active: true}) do
      {:ok, _} ->
        academic_years = Academic.list_academic_years()
        current_year = get_current_academic_year(academic_years)
        setup_progress = calculate_setup_progress(current_year)

        {:noreply,
         socket
         |> assign(:academic_years, academic_years)
         |> assign(:current_year, current_year)
         |> assign(:setup_progress, setup_progress)
         |> put_flash(:info, "Active academic year updated!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error updating academic year")}
    end
  end

  defp get_current_academic_year(academic_years) do
    Enum.find(academic_years, fn year -> year.is_active end) ||
      List.first(academic_years)
  end

  defp calculate_setup_progress(academic_year) when is_nil(academic_year), do: %{}

  defp calculate_setup_progress(academic_year) do
    # For now, we'll simulate progress based on what exists
    # In a real implementation, these would check actual data
    %{
      academic_year: if(academic_year, do: 100, else: 0),
      # TODO: Check if study programs exist for this year
      study_programs: 0,
      # TODO: Check if courses exist for this year  
      courses: 0,
      # TODO: Check if classes exist for this year
      classes: 0,
      # TODO: Check if teaching assignments exist
      teaching_assignments: 0,
      # TODO: Check if exam data has been imported
      exam_data: 0,
      # TODO: Check if exam setup is complete
      exam_setup: 0,
      # TODO: Check staff assignments
      staff_management: 0,
      # TODO: Check resource calculations
      resource_allocation: 0,
      # TODO: Check if reports are generated
      reports: 0,
      # Overall progress (academic year created = 10%)
      overall: 10
    }
  end

  defp progress_color(percentage) do
    cond do
      percentage == 0 -> "bg-gray-200"
      percentage < 50 -> "bg-red-500"
      percentage < 80 -> "bg-yellow-500"
      true -> "bg-green-500"
    end
  end

  defp status_icon(percentage) do
    cond do
      percentage == 0 -> "hero-clock"
      percentage < 100 -> "hero-arrow-path"
      true -> "hero-check-circle"
    end
  end
end
