defmodule DrasMvpWeb.StudyProgramsLive do
  use DrasMvpWeb, :live_view
  alias DrasMvp.Academic

  @impl true
  def mount(_params, _session, socket) do
    academic_years = Academic.list_academic_years()
    current_year = get_current_academic_year(academic_years)

    study_programs =
      if current_year do
        list_study_programs_for_year(current_year.id)
      else
        []
      end

    {:ok,
     socket
     |> assign(:academic_years, academic_years)
     |> assign(:current_year, current_year)
     |> assign(:study_programs, study_programs)
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
  def handle_event("create_study_program", params, socket) do
    %{
      "name" => name,
      "code" => code,
      "degree_type" => degree_type,
      "duration_years" => duration_years,
      "department" => department
    } = params

    case create_study_program(%{
           name: name,
           code: code,
           degree_type: degree_type,
           duration_years: String.to_integer(duration_years),
           department: department,
           academic_year_id: socket.assigns.current_year.id,
           status: "active"
         }) do
      {:ok, _study_program} ->
        study_programs = list_study_programs_for_year(socket.assigns.current_year.id)

        {:noreply,
         socket
         |> assign(:study_programs, study_programs)
         |> assign(:show_create_form, false)
         |> put_flash(:info, "Study program created successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error creating study program")}
    end
  end

  @impl true
  def handle_event("delete_study_program", %{"id" => id}, socket) do
    study_program = get_study_program!(id)

    case delete_study_program(study_program) do
      {:ok, _} ->
        study_programs = list_study_programs_for_year(socket.assigns.current_year.id)

        {:noreply,
         socket
         |> assign(:study_programs, study_programs)
         |> put_flash(:info, "Study program deleted successfully!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error deleting study program")}
    end
  end

  @impl true
  def handle_event("set_active_year", %{"id" => id}, socket) do
    # Deactivate all years first
    Enum.each(socket.assigns.academic_years, fn year ->
      Academic.update_academic_year(year, %{is_active: false})
    end)

    # Activate selected year
    academic_year = Academic.get_academic_year!(id)

    case Academic.update_academic_year(academic_year, %{is_active: true}) do
      {:ok, _} ->
        academic_years = Academic.list_academic_years()
        current_year = get_current_academic_year(academic_years)
        study_programs = list_study_programs_for_year(current_year.id)

        {:noreply,
         socket
         |> assign(:academic_years, academic_years)
         |> assign(:current_year, current_year)
         |> assign(:study_programs, study_programs)
         |> put_flash(:info, "Active academic year updated!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error updating academic year")}
    end
  end

  defp get_current_academic_year(academic_years) do
    Enum.find(academic_years, fn year -> year.is_active end) ||
      List.first(academic_years)
  end

  # Temporary stub functions - these will be implemented in the Academic context
  defp list_study_programs_for_year(_academic_year_id) do
    [
      %{
        id: 1,
        name: "Bachelor in Medicine",
        code: "MED-BACH",
        degree_type: "Bachelor",
        duration_years: 3,
        department: "Medicine",
        status: "active"
      },
      %{
        id: 2,
        name: "Master in Biomedical Sciences",
        code: "BIO-MAST",
        degree_type: "Master",
        duration_years: 2,
        department: "Biomedical Sciences",
        status: "active"
      }
    ]
  end

  defp create_study_program(_attrs) do
    # Stub - will implement in Academic context
    {:ok, %{id: :rand.uniform(1000)}}
  end

  defp get_study_program!(_id) do
    %{id: 1, name: "Test Program"}
  end

  defp delete_study_program(_study_program) do
    {:ok, %{}}
  end
end
