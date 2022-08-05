defmodule SpikeExample.SignupForm do
  use Spike.FormData do
    field(:company_name, :string)
    field(:plan_id, :integer)

    field(:available_plans, {:array, :map}, private: true)
  end

  validates(:company_name, presence: true)
  validates(:plan_id, presence: true, by: &__MODULE__.validate_plan_id/2)

  def validate_plan_id(nil, _context), do: :ok

  def validate_plan_id(value, context) do
    context.available_plans
    |> Enum.map(& &1.id)
    |> Enum.member?(value)
    |> if do
      :ok
    else
      {:error, "is not an available plan"}
    end
  end
end
