defmodule DrasMvp.Academic do
  @moduledoc """
  The Academic context handles academic years, courses, staff, and assignments.
  """

  import Ecto.Query, warn: false
  alias DrasMvp.Repo

  alias DrasMvp.Academic.{AcademicYear, Course, Staff, StaffAssignment, ExamRecord}

  ## Academic Years

  @doc """
  Returns the list of academic years.
  """
  def list_academic_years do
    Repo.all(from y in AcademicYear, order_by: [desc: y.start_date])
  end

  @doc """
  Gets the current active academic year.
  """
  def get_current_academic_year do
    Repo.one(from y in AcademicYear, where: y.is_active == true)
  end

  @doc """
  Gets a single academic year.
  """
  def get_academic_year!(id), do: Repo.get!(AcademicYear, id)

  @doc """
  Creates an academic year.
  """
  def create_academic_year(attrs \\ %{}) do
    %AcademicYear{}
    |> AcademicYear.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an academic year.
  """
  def update_academic_year(%AcademicYear{} = academic_year, attrs) do
    academic_year
    |> AcademicYear.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an academic year.
  """
  def delete_academic_year(%AcademicYear{} = academic_year) do
    Repo.delete(academic_year)
  end

  @doc """
  Sets an academic year as active and deactivates all others.
  """
  def set_active_academic_year(%AcademicYear{} = academic_year) do
    Repo.transaction(fn ->
      # Deactivate all years
      Repo.update_all(AcademicYear, set: [is_active: false])

      # Activate the selected year
      academic_year
      |> AcademicYear.changeset(%{is_active: true})
      |> Repo.update()
    end)
  end

  ## Courses

  @doc """
  Returns the list of courses for an academic year.
  """
  def list_courses(academic_year_id) do
    Repo.all(
      from c in Course,
        where: c.academic_year_id == ^academic_year_id,
        order_by: [asc: c.code],
        preload: [:academic_year, staff_assignments: :staff]
    )
  end

  @doc """
  Gets a single course.
  """
  def get_course!(id) do
    Repo.get!(Course, id)
    |> Repo.preload([:academic_year, staff_assignments: :staff])
  end

  @doc """
  Creates a course.
  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.
  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  ## Staff

  @doc """
  Returns the list of active staff members.
  """
  def list_staff do
    Repo.all(
      from s in Staff,
        where: s.is_active == true,
        order_by: [asc: s.last_name, asc: s.first_name],
        preload: [staff_assignments: [:course]]
    )
  end

  @doc """
  Gets a single staff member.
  """
  def get_staff!(id) do
    Repo.get!(Staff, id)
    |> Repo.preload(staff_assignments: [:course])
  end

  @doc """
  Creates a staff member.
  """
  def create_staff(attrs \\ %{}) do
    %Staff{}
    |> Staff.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a staff member.
  """
  def update_staff(%Staff{} = staff, attrs) do
    staff
    |> Staff.changeset(attrs)
    |> Repo.update()
  end

  ## Staff Assignments

  @doc """
  Creates a staff assignment.
  """
  def create_staff_assignment(attrs \\ %{}) do
    %StaffAssignment{}
    |> StaffAssignment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a staff assignment.
  """
  def update_staff_assignment(%StaffAssignment{} = assignment, attrs) do
    assignment
    |> StaffAssignment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a staff assignment.
  """
  def delete_staff_assignment(%StaffAssignment{} = assignment) do
    Repo.delete(assignment)
  end

  ## Exam Records

  @doc """
  Creates an exam record (typically from CSV import).
  """
  def create_exam_record(attrs \\ %{}) do
    %ExamRecord{}
    |> ExamRecord.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns exam records for a course.
  """
  def list_exam_records(course_id) do
    Repo.all(
      from e in ExamRecord,
        where: e.course_id == ^course_id,
        order_by: [desc: e.exam_date]
    )
  end
end
