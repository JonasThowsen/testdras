defmodule DrasMvp.Academic.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :code, :string
    field :name, :string
    field :description, :string
    field :credits, :decimal
    field :department, :string
    field :level, :string
    field :semester, :string
    field :status, :string, default: "draft"

    belongs_to :academic_year, DrasMvp.Academic.AcademicYear
    has_many :staff_assignments, DrasMvp.Academic.StaffAssignment
    has_many :exam_records, DrasMvp.Academic.ExamRecord

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [
      :code,
      :name,
      :description,
      :credits,
      :department,
      :level,
      :semester,
      :status,
      :academic_year_id
    ])
    |> validate_required([:code, :name, :academic_year_id])
    |> validate_inclusion(:status, ["draft", "active", "completed", "archived"])
    |> unique_constraint([:code, :academic_year_id])
  end
end
