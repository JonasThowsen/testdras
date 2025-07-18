defmodule DrasMvp.Academic.AcademicYear do
  use Ecto.Schema
  import Ecto.Changeset

  schema "academic_years" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :status, :string, default: "planning"
    field :is_active, :boolean, default: false
    field :course_setup_count, :integer, default: 0
    field :staff_assignment_count, :integer, default: 0
    field :resource_allocation_count, :integer, default: 0

    has_many :courses, DrasMvp.Academic.Course

    timestamps()
  end

  def changeset(academic_year, attrs) do
    academic_year
    |> cast(attrs, [
      :name,
      :start_date,
      :end_date,
      :status,
      :is_active,
      :course_setup_count,
      :staff_assignment_count,
      :resource_allocation_count
    ])
    |> validate_required([:name, :start_date, :end_date])
    |> validate_inclusion(:status, ["planning", "active", "completed", "archived"])
    |> unique_constraint(:name)
  end
end
