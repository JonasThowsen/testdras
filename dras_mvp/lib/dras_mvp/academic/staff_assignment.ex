defmodule DrasMvp.Academic.StaffAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "staff_assignments" do
    field :assignment_type, :string
    field :workload_percentage, :decimal, default: Decimal.new("0.0")
    field :hours_allocated, :decimal, default: Decimal.new("0.0")
    field :status, :string, default: "pending"
    field :notes, :string

    belongs_to :staff, DrasMvp.Academic.Staff
    belongs_to :course, DrasMvp.Academic.Course

    timestamps()
  end

  def changeset(staff_assignment, attrs) do
    staff_assignment
    |> cast(attrs, [
      :staff_id,
      :course_id,
      :assignment_type,
      :workload_percentage,
      :hours_allocated,
      :status,
      :notes
    ])
    |> validate_required([:staff_id, :course_id, :assignment_type])
    |> validate_inclusion(:assignment_type, ["lecturer", "examiner", "assistant"])
    |> validate_inclusion(:status, ["pending", "confirmed", "completed"])
    |> unique_constraint([:staff_id, :course_id, :assignment_type])
  end
end
