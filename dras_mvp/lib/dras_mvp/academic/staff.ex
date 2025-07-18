defmodule DrasMvp.Academic.Staff do
  use Ecto.Schema
  import Ecto.Changeset

  schema "staff" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :title, :string
    field :department, :string
    field :role, :string, default: "lecturer"
    field :workload_limit, :decimal, default: Decimal.new("100.0")
    field :is_active, :boolean, default: true

    has_many :staff_assignments, DrasMvp.Academic.StaffAssignment

    timestamps()
  end

  def changeset(staff, attrs) do
    staff
    |> cast(attrs, [
      :first_name,
      :last_name,
      :email,
      :title,
      :department,
      :role,
      :workload_limit,
      :is_active
    ])
    |> validate_required([:first_name, :last_name, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_inclusion(:role, ["lecturer", "professor", "assistant", "examiner"])
    |> unique_constraint(:email)
  end
end
