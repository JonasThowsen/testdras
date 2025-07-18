defmodule DrasMvpWeb.CourseManagementLive do
  use DrasMvpWeb, :live_view
  alias DrasMvp.Academic

  @impl true
  def mount(_params, _session, socket) do
    academic_years = Academic.list_academic_years()
    current_year = get_current_academic_year(academic_years)

    courses =
      if current_year do
        list_courses_for_year(current_year.id)
      else
        []
      end

    staff = list_staff()
    study_programs = list_study_programs_for_year(current_year && current_year.id)

    {:ok,
     socket
     |> assign(:academic_years, academic_years)
     |> assign(:current_year, current_year)
     |> assign(:courses, courses)
     |> assign(:staff, staff)
     |> assign(:study_programs, study_programs)
     |> assign(:show_create_form, false)
     |> assign(:show_assign_form, false)
     |> assign(:selected_course, nil)
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
  def handle_event("show_assign_form", %{"course_id" => course_id}, socket) do
    course = Enum.find(socket.assigns.courses, fn c -> c.id == String.to_integer(course_id) end)

    {:noreply,
     socket
     |> assign(:show_assign_form, true)
     |> assign(:selected_course, course)}
  end

  @impl true
  def handle_event("hide_assign_form", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_assign_form, false)
     |> assign(:selected_course, nil)}
  end

  @impl true
  def handle_event("create_course", params, socket) do
    %{
      "code" => code,
      "name" => name,
      "credits" => credits,
      "department" => department,
      "level" => level,
      "semester" => semester
    } = params

    case create_course(%{
           code: code,
           name: name,
           credits: String.to_float(credits),
           department: department,
           level: level,
           semester: semester,
           academic_year_id: socket.assigns.current_year.id,
           status: "active"
         }) do
      {:ok, _course} ->
        courses = list_courses_for_year(socket.assigns.current_year.id)

        {:noreply,
         socket
         |> assign(:courses, courses)
         |> assign(:show_create_form, false)
         |> put_flash(:info, "Course created successfully!")}

      _ ->
        {:noreply, put_flash(socket, :error, "Error creating course")}
    end
  end

  @impl true
  def handle_event("assign_staff", params, socket) do
    %{
      "staff_id" => staff_id,
      "assignment_type" => assignment_type,
      "hours_allocated" => hours_allocated
    } = params

    case assign_staff_to_course(%{
           staff_id: String.to_integer(staff_id),
           course_id: socket.assigns.selected_course.id,
           assignment_type: assignment_type,
           hours_allocated: String.to_float(hours_allocated),
           workload_percentage: calculate_workload_percentage(String.to_float(hours_allocated))
         }) do
      {:ok, _assignment} ->
        courses = list_courses_for_year(socket.assigns.current_year.id)

        {:noreply,
         socket
         |> assign(:courses, courses)
         |> assign(:show_assign_form, false)
         |> assign(:selected_course, nil)
         |> put_flash(:info, "Staff assigned successfully!")}

      _ ->
        {:noreply, put_flash(socket, :error, "Error assigning staff")}
    end
  end

  @impl true
  def handle_event("delete_course", %{"id" => id}, socket) do
    course = Enum.find(socket.assigns.courses, fn c -> c.id == String.to_integer(id) end)

    case delete_course(course) do
      {:ok, _} ->
        courses = list_courses_for_year(socket.assigns.current_year.id)

        {:noreply,
         socket
         |> assign(:courses, courses)
         |> put_flash(:info, "Course deleted successfully!")}

      _ ->
        {:noreply, put_flash(socket, :error, "Error deleting course")}
    end
  end

  defp get_current_academic_year(academic_years) do
    Enum.find(academic_years, fn year -> year.is_active end) ||
      List.first(academic_years)
  end

  defp calculate_workload_percentage(hours_allocated) do
    # Assuming 40 hours per week * 15 weeks = 600 total hours per semester
    total_semester_hours = 600
    Float.round(hours_allocated / total_semester_hours * 100, 2)
  end

  # Temporary stub functions - these will be implemented in the Academic context
  defp list_courses_for_year(_academic_year_id) do
    [
      %{
        id: 1,
        code: "MED-1001",
        name: "Introduction to Medicine",
        credits: 6.0,
        department: "Medicine",
        level: "Bachelor",
        semester: "Fall",
        status: "active",
        assigned_staff: [
          %{name: "Dr. Smith", type: "lecturer", hours: 40.0},
          %{name: "Prof. Johnson", type: "examiner", hours: 8.0}
        ]
      },
      %{
        id: 2,
        code: "BIO-2001",
        name: "Advanced Biochemistry",
        credits: 4.0,
        department: "Biomedical Sciences",
        level: "Master",
        semester: "Spring",
        status: "draft",
        assigned_staff: []
      }
    ]
  end

  defp list_staff do
    [
      %{id: 1, name: "Dr. Smith", department: "Medicine", workload_limit: 100.0},
      %{id: 2, name: "Prof. Johnson", department: "Medicine", workload_limit: 100.0},
      %{id: 3, name: "Dr. Brown", department: "Biomedical Sciences", workload_limit: 100.0}
    ]
  end

  defp list_study_programs_for_year(_academic_year_id) do
    [
      %{id: 1, name: "Bachelor in Medicine", code: "MED-BACH"},
      %{id: 2, name: "Master in Biomedical Sciences", code: "BIO-MAST"}
    ]
  end

  defp create_course(_attrs), do: {:ok, %{id: :rand.uniform(1000)}}
  defp assign_staff_to_course(_attrs), do: {:ok, %{}}
  defp delete_course(_course), do: {:ok, %{}}
end
